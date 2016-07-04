//
//  UserProfileViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/21/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Alamofire
import RxAlamofire

import RxSwift
import RxCocoa

import ObjectMapper

import FDTake
import FBSDKLoginKit

enum UserProfileEditingState {
    case NoEditing
    case ShowEditing
    case ShowConfirmation
}

enum UserProfileEditingError : ErrorType {
    
    case NameDuplication
    
}

class UserProfileViewModel {
    
    private var userVariable: Variable<User>
    
    var userDriver: Driver<User> {
        return userVariable.asDriver()
    }
    let errorMessage: Variable<String?> = Variable(nil)
    
    var editingState: Variable<UserProfileEditingState> = Variable(.NoEditing)
    
    
    var usernameTextBoxViewModel = TextBoxViewModel(displayText: "")
    private var fdTakeController: FDTakeController = {
        let d = FDTakeController()
        d.allowsVideo = false
        return d
    }()
    
    let uploadProgress = Variable<Float?>(nil)
    
    private let bag = DisposeBag()
    
    let feedViewModel = FeedViewModel()
    let followingViewModel: UserProfileFollowingViewModel
    
    init(userDescriptor: User) {
        
        ///initial state
        userVariable = Variable(userDescriptor)
        let isCurrentUser = userDescriptor.id == User.currentUser()!.id
        editingState = Variable( isCurrentUser ? .ShowEditing : .NoEditing )
        
        followingViewModel = UserProfileFollowingViewModel(user: userDescriptor)
        
        ///username editing
        usernameTextBoxViewModel = TextBoxViewModel(displayText: userDescriptor.username)
        usernameTextBoxViewModel.text.asObservable()
            .filter { $0 != nil }.map { $0! }
            .map { [unowned self] username in
                var user = self.userVariable.value
                user.username = username
                return user
            }
            .bindTo(userVariable)
            .addDisposableTo(bag)
        
        ///image editing
        fdTakeController.rxex_photo()
            .map { [unowned self] image in
                let tempURL = "com.nightlife.temporayAvatar"
                ImageRetreiver.registerImage(image, forKey: tempURL)
                
                var user = self.userVariable.value
                user.pictureURL = tempURL
                return user
            }
            .bindTo(userVariable)
            .addDisposableTo(bag)
        
        ////refreshing user info
        Alamofire.request(UserRouter.Info(userId: userDescriptor.id))
            .rx_responseJSON()
            .map { response -> User in
                
                guard let rootJSON = response.1["user"] as? [String : AnyObject] else {
                    fatalError("Error recognising server respnse")
                }
                
                let mapper = Mapper<User>()
                guard let user = mapper.map(rootJSON) else {
                    fatalError("Error parsing user from server respnse")
                }
                
                /// .Info router provides the most full and recent data about user
                /// So we will force update local storage here
                user.saveEntity()
                
                return user
            }
            .bindTo(userVariable)
            .addDisposableTo(bag)
        
        feedViewModel.dataProvider.value = UserProfileDataProvider(user: userDescriptor)
    }
    
    func editPhoto() {
        fdTakeController.present()
    }
    
    func uploadEdits() {
        
        Alamofire.upload(UserRouter.Update,
                         multipartFormData: { formData in
                            
                            if let avatar = ImageRetreiver.cachedImageForKey("com.nightlife.temporayAvatar") {
                                formData.appendBodyPart(data: UIImageJPEGRepresentation(avatar, 0.6)!,
                                    name: "file",
                                    fileName: "image.jpg",
                                    mimeType: "image/jpg")
                            }
                            
                            formData.appendBodyPart(data: "\(self.userVariable.value.id)".dataUsingEncoding(NSUTF8StringEncoding)!,
                                name: "user_pk")
                            
                            formData.appendBodyPart(data: "\(self.userVariable.value.username)".dataUsingEncoding(NSUTF8StringEncoding)!,
                                name: "user_name")
                            
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    
                    upload.rx_progress()
                        .map { $0.floatValue() }
                        .bindTo(self.uploadProgress)
                        .addDisposableTo(self.bag)
                      
                    
                    upload
                        .rx_responseJSON()
                        .flatMap { userJSON -> Observable<User> in
                            
                            ///yet again awful data collecting from server
                            guard let json = userJSON.1 as? [String : AnyObject] else {
                                fatalError("Error recognizing server sturcture");
                            }
                            
                            if let duplication = json["data"] as? String where
                                duplication == "Name duplication" {
                                return Observable.error(UserProfileEditingError.NameDuplication)
                            }
                            
                            guard let username = json["username"] as? String,
                                  let pictureURL = json["profile_image"] as? String else {
                                fatalError("Error recognizing server sturcture");
                            }
                            
                            if let newAvatar = ImageRetreiver.cachedImageForKey("com.nightlife.temporayAvatar") {
                                ImageRetreiver.registerImage(newAvatar, forKey: pictureURL)
                                ImageRetreiver.flushImageForKey("com.nightlife.temporayAvatar")
                            }
                            
                            var newCurrentUser = User.currentUser()!
                            newCurrentUser.username = username
                            newCurrentUser.pictureURL = pictureURL
                            
                            newCurrentUser.saveLocally()
                            
                            self.editingState.value = .ShowEditing
                            
                            return Observable.just(newCurrentUser)
                        }
                        .catchError({ (er) -> Observable<User> in
                            
                            if (er as? UserProfileEditingError) == UserProfileEditingError.NameDuplication {
                                self.errorMessage.value = "This username is alreday taken, please choose another one"
                            }
                            else {
                                print(er)
                            }
                            
                            return Observable.just(self.userVariable.value)
                        })
                        .bindTo(self.userVariable)
                        .addDisposableTo(self.bag)
                    
                case .Failure(let encodingError):
                    
                    assert(false, "\(encodingError)")
                    
                }
        })

    }
    
    func logoutAction() {
        NotificationManager.flushDeviceToken()
        LocationManager.instance.endMonitoring()
        
        ImageRetreiver.flushCache()
        
        AccessToken.token = nil
        User.currentUser()?.logout()
        FBSDKLoginManager().logOut()
        CheckinContext.drainAllCheckins()
        
        User.storage = [:]
        Club.storage = [:]
        Message.storage = [:]
        MediaItem.storage = [:]
        
        MainRouter.sharedInstance.authorizationRout(animated: true)
    }
    
    func deleteProfile() {
        Alamofire.request(UserRouter.DeleteProfile)
            .responseJSON { _ in
                self.logoutAction()
            }
    }
    
}

class UserProfileDataProvider: FeedDataProvider {
    
    private let user: User
    init(user: User) {
        self.user = user
        
    }
    
    private var loadOnceFlag = true
    func loadBatch(batch: Batch) -> Observable<[FeedDataItem]> {

        if loadOnceFlag {
            loadOnceFlag = false
            return Alamofire.request(UserRouter.Info(userId: user.id))
                .rx_responseJSON()
                .map { response -> [FeedDataItem] in
                    
                    guard let rootJSON = response.1 as? [String : AnyObject],
                        let lastReportsJSON = rootJSON["last_reports"] as? [[String : AnyObject]] else {
                            fatalError("Error recognising server respnse")
                    }
                    
                    return lastReportsJSON.map { FeedDataItem(feedItemJSON: $0, postOwner: self.user)! }
            }
        }
        else {
            return Observable.just([])
        }
    }
}

extension FDTakeController {
    
    func rxex_photo() -> Observable<UIImage> {
        
        return Observable.create{ observer in
        
            self.didGetPhoto = { image, info in
                observer.onNext(image)
                //observer.onCompleted()
            }
            
            return NopDisposable.instance
        }
        
    }
    
}