//
//  MessageListRouter.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

enum MessagesRouter : AuthorizedRouter {
    
    case List
    case MessageDetails(id: Int)
    case Delete(message: Message)
    case MarkRead(message: Message)
    
}

extension MessagesRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self {
            
        case .List:
            
            return self.authorizedRequest(.GET,
                                          path: "messages/",
                                          encoding: .URL,
                                          body: [:])
            
            
        case .MessageDetails(let pk):
            
            return self.authorizedRequest(.GET,
                                          path: "messages/\(pk)/",
                                          encoding: .URL,
                                          body: [:])
            
        case .Delete(let message):
            
            return self.authorizedRequest(.DELETE,
                                          path: "messages/",
                                          encoding: .JSON,
                                          body: ["message_pk" : message.id])
            
        case .MarkRead(let message):
            
            return self.authorizedRequest(.POST,
                                          path: "messages/is_readed/",
                                          encoding: .URL,
                                          body: [
                                            "message_pk" : message.id
                                                ])
            
        }
    }
    
}