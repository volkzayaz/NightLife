//
//  UserRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/16/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

enum UserRouter : AuthorizedRouter {
    
    /**
     *  Retreives information about user with given Id
     *  if no id passed - retreives information about currently logged in user
     *  authorized user is required
     */
    case Info(userId :Int?)

    /**
     *  Retreives list of users which names satisfy given query
     */
    case List(filterQuery: String?)
    
    /**
     * Associate device token with currently logged in user
     */
    case LinkDeviceToken(deviceToken: NSData)

    /**
     * Unlink device token from currently logged in user
     */
    case UnLinkDeviceToken
    
    /**
     * Endpoint for updating user's username and optionaly avatar using form data upload 
     */
    case Update
    
    /**
     *  - Deletes profile
     */
    case DeleteProfile
    
    
    case SendTestPush
}

extension UserRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self{
            
        case .Info(let userId):
            
            var idComponent: String? = nil
            if let id = userId {
                idComponent = "\(id)"
            } else { idComponent = "me" }
            
            return self.authorizedRequest(.GET,
                path: "users/\(idComponent!)/",
                encoding: .URL,
                body: [:])
            
        case .List(let query):
            
            var body: [String: AnyObject] = [:]
            if let q = query {
                body["search"] = q
            }
            
            return self.authorizedRequest(.GET,
                path: "users/",
                encoding: .URL,
                body: body)
            
        case .LinkDeviceToken(let deviceToken):
            
            return self.authorizedRequest(.POST,
                                          path: "dev_token/",
                                          encoding: .URL,
                                          body: ["dev_token" : deviceToken.hexadecimalString])
            
        case .UnLinkDeviceToken:
            
            return self.authorizedRequest(.DELETE,
                                          path: "dev_token/",
                                          encoding: .URL,
                                          body: [:])
            
        case .SendTestPush:
            
            return self.authorizedRequest(.PUT,
                                          path: "dev_token/",
                                          encoding: .URL,
                                          body: [:])
            
        case .Update:
            
            return self.authorizedRequest(.POST,
                                          path: "files/",
                                          encoding: .URL,
                                          body: [:])
            
        case .DeleteProfile:
            
            guard let user = User.currentUser() else { fatalError("Can't delete User profile without logged in user") }
            
            return self.authorizedRequest(.DELETE,
                                          path: "users/\(user.id)",
                                          encoding: .URL,
                                          body: [:])
            
        }
    }
    
}