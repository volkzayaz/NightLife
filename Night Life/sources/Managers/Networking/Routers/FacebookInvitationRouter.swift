//
//  FacebookInvitationRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

enum FacebookInvitationRouter : AuthorizedRouter {
    
    case SendInvitation
    case UpdateToken(token: String)
    
}

extension FacebookInvitationRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self {
        case .SendInvitation:
            return self.authorizedRequest(.POST,
                                          path: "/fb/post/",
                                          encoding: .URL,
                                          body: [:])
            
        case .UpdateToken(let token):
            return self.authorizedRequest(.PUT,
                                          path: "/fb/post/",
                                          encoding: .URL,
                                          body: ["fb_token" : token])
        
        }
        
        
    }
    
}