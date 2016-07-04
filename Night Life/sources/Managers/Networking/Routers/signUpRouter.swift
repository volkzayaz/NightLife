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

enum SignUpRouter: AuthorizedRouter {

    
    
    case SignUpWithEmail(email: String, username: String, password: String, clientId: String)
}

extension SignUpRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self{

        case .SignUpWithEmail(let email, let username, let password, let clientId):

            return self.unauthorizedRequest(.POST,
                                          path: "users/eml_register/",
                                          encoding: .URL,
                                          body: ["email" : email, "username" : username, "password" : password, "client_id": clientId])
            
        }
    }
}