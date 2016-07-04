//
//  SignUpRouter.swift
//  GlobBar
//
//  Created by admin on 16.05.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import Alamofire
import RxAlamofire

import ObjectMapper

enum SignInRouter: AuthorizedRouter {
    
    case SignInWithEmail(email: String, password: String, clientId: String)
}

extension SignInRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self{
            
        case .SignInWithEmail(let email, let password, let clientId):
            
            return self.unauthorizedRequest(.POST,
                                            path: "users/eml_login/",
                                            encoding: .URL,
                                            body: ["email" : email, "password" : password, "client_id": clientId])
        }
    }
}