//
//  UserProfileFollowingViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/21/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire

enum FollowingState {
    case Nothing
    case Requested
    case Following
}

class UserProfileFollowingViewModel {
    
    private let user: Variable<User>
    private let bag: DisposeBag = DisposeBag()
    
    var followButtonText: Driver<String> {
        return user.asDriver().map { user in
            guard let type = user.relationType else {
                return "follow"
            }
            
            switch type {
            case .Request:
                return "follow"
                
            case .Following: fallthrough
            case .Follower:
                return "unfollow"
            }
        }
    }
    
    var followButtonEnabled: Driver<Bool> {
        return user.asDriver().map { user in
            if let type = user.relationType where
               type == .Request {
                return false
            }
            
            return true
        }
    }
    
    var followButtonHidden: Driver<Bool> {
        
        return user.asDriver().map { $0 == User.currentUser() }
        
    }
    
    init(user: User) {
        guard let u = user.observableEntity() else {
            fatalError("Can't perform following actions on user that is not saved to InMemmoryStorage")
        }
        
        self.user = u
    }
    
    func performAction() {
        
        if user.value.relationType == nil {
            performFollowRequest()
        }
        else if let type = user.value.relationType where type == .Following {
            performUnFollowAction()
        }
    }
}

extension UserProfileFollowingViewModel {
    
    private func performFollowRequest() {
        let router = RelationRouter.PostRelation(user: user.value, type: .Request, createAction: true)
        
        Alamofire.request(router)
            .rx_responseJSON()
            .subscribeNext { [unowned self] response in
                
                var user = self.user.value
                user.relationType = .Request
                user.saveEntity()
                
            }
            .addDisposableTo(bag)
    }
    
    private func performUnFollowAction() {
        let router = RelationRouter.PostRelation(user: user.value, type: .Following, createAction: false)
        
        Alamofire.request(router)
            .rx_responseJSON()
            .subscribeNext { [unowned self] response in
                
                var user = self.user.value
                user.relationType = nil
                user.followingCount? -= 1
                user.saveEntity()
                
            }
            .addDisposableTo(bag)
    }
   
}