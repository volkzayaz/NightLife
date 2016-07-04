//
//  InstagramAuthenticator.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/11/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift

class InstagramAuthenticator : ExternalAuthenticator {
    
    static private let backendIdentifier = "instagram"
    
    func authenticateUser(onController maybeController: UIViewController?) -> Observable<RemoteAuthData> {
        
        guard let controller = maybeController else {
            return Observable.just(RemoteAuthData(token: "", backendIdentifier: InstagramAuthenticator.backendIdentifier))
        }
        
        return Observable.create { observer in
            
            let loginController = InstagramLoginViewController(presenter: controller)
                { (maybeToken, maybeError) -> Void in
                
                    guard maybeError == nil else {
                        observer.onError(maybeError!)
                        return
                    }
                    
                    /// "We expect accessToken to be valid if error is nil"
                    let token = maybeToken!
                    
                    let data = RemoteAuthData(token: token,
                        backendIdentifier: InstagramAuthenticator.backendIdentifier)
                    
                    
                    observer.on(.Next(data))
                    observer.onCompleted()
            }
            
            loginController.presentLogin()
            
            return AnonymousDisposable { loginController.stopLoading() }
            
        }//.share()
        
    }
    
    
}