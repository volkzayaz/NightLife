//
//  AuthorizationRouter.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

enum AccessTokenRouter : AuthorizedRouter {
    
    /**
     *  Exchanges facebook/instagram token for NightLifeToken
     */
    case ExternalLogin(authData : RemoteAuthData)

    case SignUp(username: String, password: String, email: String)
    
    case LogIn(email: String, password: String)
}

extension AccessTokenRouter {
    
    var URLRequest: NSMutableURLRequest {
    
        switch self {
            
        case .ExternalLogin(let authData):
            
            return self.unauthorizedRequest(.POST,
                                            path: "auth/convert-token/",
                                            encoding: .URL,
                                            body: [
                                                "grant_type" : "convert_token",
                                                "client_id" : GatewayConfiguration.clientId,
                                                "client_secret" : GatewayConfiguration.clientSecret,
                                                "backend" : authData.backendIdentifier,
                                                "token" : authData.token
                ])
         
        case .LogIn(let email, let password):
            
            return self.unauthorizedRequest(.POST,
                                            path: "users/eml_login/",
                                            encoding: .URL,
                                            body: ["email" : email,
                                                "password" : password,
                                                "client_id": GatewayConfiguration.clientId])
            
        case .SignUp(let username, let password, let email):
            
            return self.unauthorizedRequest(.POST,
                                            path: "users/eml_register/",
                                            encoding: .URL,
                                            body: ["email" : email,
                                                "username" : username,
                                                "password" : password,
                                                "client_id": GatewayConfiguration.clientId])
            
        }
        
    }
    
}