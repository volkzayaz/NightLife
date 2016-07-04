//
//  AuthorizationManager.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

enum AuthorizationError : ErrorType {
    
    case CustomError(description: String?)
    
}

enum AuthorizationManager { }
extension AuthorizationManager {
    
    static func loginUserWithRouter(router: AccessTokenRouter) -> Observable<String?> {
        
        return Alamofire.Manager.sharedInstance
            .request(router)
            .rx_responseJSON()
            .flatMap { response -> Observable<String?> in
                
                guard let nightLifeAcessToken = response.1["access_token"] as? String else {
                    
                    let reason = response.1["data"] as? String
                    return Observable.error(AuthorizationError.CustomError(description: reason))
                    
                }
                
                AccessToken.token = nightLifeAcessToken
                return Observable.just(nightLifeAcessToken)
            }
    }
 
    static func currentUserDetails() -> Observable<[String : AnyObject]> {
        
        return Alamofire.Manager.sharedInstance
            .rx_request(UserRouter.Info(userId: nil))
            .flatMap { $0.rx_responseJSON() }
            .map { responce -> [String : AnyObject] in
                
                guard let rootJSON = responce.1["user"] as? [String : AnyObject] else {
                    fatalError("error recognizing server response structure")
                }
                
                return rootJSON
        }

        
    }
    
}
