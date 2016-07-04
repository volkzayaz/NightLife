//
//  FacebookAuthenticator.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/12/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import FBSDKLoginKit

enum FacebookError : ErrorType {
    case UserCanceled
    case InternalError(error: NSError)
}

class FacebookAuthenticator : ExternalAuthenticator {

    static private let backendIdentifier = "facebook"
    
    func authenticateUser(onController maybeController: UIViewController?) -> Observable<RemoteAuthData> {
        
        guard let controller = maybeController else {
            return Observable.just( RemoteAuthData(token: "", backendIdentifier: FacebookAuthenticator.backendIdentifier) )
        }
        
        return Observable.create { observer in
            
            let manager = FBSDKLoginManager()
            
            manager.loginBehavior = .Browser
            
            manager.logInWithReadPermissions(["public_profile", "email"], fromViewController: controller)  { (result, error) in
                
                if error != nil {
                    observer.onError(FacebookError.InternalError(error: error))
                    return
                }
                
                guard result.isCancelled == false else {
                    observer.onError(FacebookError.UserCanceled)
                    return
                }
                
                observer.onNext(
                    RemoteAuthData(token: result.token.tokenString,
                    backendIdentifier: FacebookAuthenticator.backendIdentifier))
                observer.onCompleted()
                
            }
            
            return NopDisposable.instance
        }
    }
    
    static func reauthentiacteForPublishObservable(onController controller:UIViewController) -> Observable<RemoteAuthData> {
        
        return Observable.create { observer in
            
            let manager = FBSDKLoginManager()
            
            manager.loginBehavior = .Browser
            
            manager.logInWithPublishPermissions(["publish_actions"], fromViewController: controller) {
                (result, error) in
                
                if error != nil {
                    observer.onError(FacebookError.InternalError(error: error))
                    return
                }
                
                guard result.isCancelled == false else {
                    observer.onError(FacebookError.UserCanceled)
                    return
                }
                
                observer.onNext(
                    RemoteAuthData(token: result.token.tokenString,
                       backendIdentifier: FacebookAuthenticator.backendIdentifier))
                observer.onCompleted()
                
            }
            
            return NopDisposable.instance
        }

        
    }
    
}