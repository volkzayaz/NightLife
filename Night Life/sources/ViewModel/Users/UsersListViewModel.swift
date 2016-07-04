//
//  UsersListViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/21/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire
import ObjectMapper

enum UserListMode {
    case Following
    case Follower
}

typealias RelationActionMetadata = (user: User, type: RelationType, isCreate: Bool)

class UsersListViewModel {
    
    let displayData: Driver<[UserSection]>
    
    private let usersViewModels: Variable<[UserViewModel]> = Variable([])
    
    private let bag = DisposeBag()
    
    let searchBarObservable: Variable<Observable<String>?> = Variable(nil)
    
    let selectedUser: Variable<UserViewModel?> = Variable(nil)
    let shouldDisplaySearchBar: Bool
    let message: Variable<String?> = Variable(nil)
    let title: Variable<String?> = Variable(nil)
    
    init(mode: UserListMode) {
        
        shouldDisplaySearchBar = mode == .Following
        
        displayData = usersViewModels.asDriver()
            .map { items in
                
                return [ UserSection(items: items ) ]
            }
        
        ///observing actions of UserViewModels
        let userActionsObservable =
        displayData.map{ $0.first?.items }
            .filter { $0 != nil }.map { $0! } ///get currently displayed non-nil UserViewModels
            .map{ $0.map( { $0.performedAction.asObservable() } ) } ///map them to their performedAction Variables
            .asObservable()
            .flatMapLatest { $0.toObservable().merge() } ///Merge Variables into one sequence and observe only most recent batch
            .catchError{ [unowned self] (er) -> Observable<UserViewModelAction?> in
                
                self.message.value = "Error performing request. Details: \(er)"
                
                return Observable.just(nil)
            }
            .filter { $0 != nil }.map { $0! } ///ignore empty performed actions
        
        userActionsObservable
            .subscribeNext { [unowned self] item in
            
                var metadata: RelationActionMetadata? = nil
                var newActions : [UserViewModelActionType]? = nil
                
                switch item.type {
                case .SendFollowRequest:
                    metadata = (item.user, RelationType.Request, true)
                    
                case .DeclineFollowRequest:
                    metadata = (item.user, RelationType.Request, false)
                    
                    
                case .AcceptFollowRequest:
                    metadata = (item.user, RelationType.Following, true)
                    newActions = [UserViewModelActionType.Block]
                    
                case .Unsubscribe:
                    metadata = (item.user, RelationType.Following, false)
                    
                case .Block:
                    metadata = (item.user, RelationType.Follower, false)
                    
                    
                }
                
                self.performActionRequest(metadata!, newActions: newActions)

            }
            .addDisposableTo(bag)
        
        
        
        switch mode {
        case .Follower:
            Observable.combineLatest(followRequestsObservable(), followersObservable()) { $0 + $1 }
                .bindTo(usersViewModels)
                .addDisposableTo(bag)
            title.value = "My Followers"
            
            
        case .Following:
            followingModeListObservable()
                .bindTo(usersViewModels)
                .addDisposableTo(bag)
            title.value = "I'm Following"
            
        }
        
    }
    
    func userViewModelSelected(selectedViewModel: UserViewModel) {
        selectedUser.value = selectedViewModel
    }
    
}

extension UsersListViewModel {
    
    private func followRequestsObservable() -> Observable<[UserViewModel]> {
        return self.performUserListRequest(RelationRouter.FollowRequests).map {
            $0.map { UserViewModel(user: $0,
                actions: [
                    UserViewModelActionType.DeclineFollowRequest,
                    UserViewModelActionType.AcceptFollowRequest]) }
        }
    }
    
    private func followersObservable() -> Observable<[UserViewModel]> {
        return self.performUserListRequest(RelationRouter.Followers).map {
            $0.map { UserViewModel(user: $0, actions: [UserViewModelActionType.Block]) }
        }
    }
    
    private func followingObservable() -> Observable<[UserViewModel]> {
        return self.performUserListRequest(RelationRouter.Following).map {
                $0.map { UserViewModel(user: $0, actions: [UserViewModelActionType.Unsubscribe]) }
            }
            .share()
    }
    
    private func performUserListRequest(router: AuthorizedRouter) -> Observable<[User]> {
        return Alamofire.request(router)
            .rx_responseJSON()
            .map { respose in
                
                guard let rootJSON = respose.1 as? [[String : AnyObject]] else {

                    fatalError("error recognizing server response structure")
                }
                
                var usersJSON: [[String: AnyObject]]? = nil
                if rootJSON.first?["username"] == nil
                {
                    usersJSON = rootJSON.flatMap( { $0["user"] as? [String : AnyObject] } )
                }
                else
                {
                    usersJSON = rootJSON
                }
                
                let mapper = Mapper<User>()
                
                guard let users = mapper.mapArray(usersJSON) else {
                    fatalError("error parsing server response structure")
                }
                
                users.filter{ $0.observableEntity() == nil }
                    .forEach{ $0.saveEntity() }
                
                return users
        }
    }
}

extension UsersListViewModel {
    
    private func performActionRequest(metadata: RelationActionMetadata, newActions: [UserViewModelActionType]?) {
        
        var items = self.usersViewModels.value
        
        guard let index = items.indexOf( { $0.user == metadata.user } ) else {
            fatalError("Logic error. Passed user does not correspond to any user that is currently displayed")
        }
        
        let router = RelationRouter.PostRelation(user: metadata.user, type: metadata.type, createAction: metadata.isCreate)
        
        Alamofire.request(router)
            .rx_responseJSON()
            .map { response -> String in
                
                if let actions = newActions {
                    
                    let viewModel = items[index]
                    let newViewModel = UserViewModel(user: viewModel.user, actions: actions)
                    items[index] = newViewModel
                    self.usersViewModels.value = items
                    
                }
                else {
                    items.removeAtIndex(index)
                    self.usersViewModels.value = items
                }
                
                return ""
            }
            .catchError { Observable.just("Error performing request. Details: \($0)") }
            .bindTo(message)
            .addDisposableTo(bag)
    }

}

extension UsersListViewModel {
    
    private func followingModeListObservable() -> Observable<[UserViewModel]> {
        
        return searchBarObservable.asObservable()
            .filter { $0 != nil }.map { $0! } ///waiting until query emitter is set up
            .switchLatest()
            .catchErrorJustReturn("")
            .filter{ query in ///ignoring queries with less than 2 symbols
                let length = query.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
                return length > 2 || length == 0
            }
            .throttle(0.3, scheduler: MainScheduler.instance) ///taking care of fast typers
            .flatMapLatest { [unowned self] query -> Observable<[UserViewModel]> in  /// executing backend query
                guard query.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 else {
                    ///followers list
                    return self.followingObservable()
                }
                
                return self.performUserListRequest(UserRouter.List(filterQuery: query)).map {
                    $0.map { UserViewModel(user: $0, actions: [UserViewModelActionType.SendFollowRequest]) }
                }
            }
        
    }
    
}