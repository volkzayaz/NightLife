//
//  RelationRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/22/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

enum RelationType : String {
    case Request = "request"
    case Following = "following"
    case Follower = "follower"
}

enum RelationRouter : AuthorizedRouter {
    
    case PostRelation(user: User, type: RelationType, createAction: Bool)
    
    case FollowRequests
    case Followers
    case Following
}

extension RelationRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self{
        case .PostRelation(let user, let type, let createAction):
            
            return self.authorizedRequest(.POST,
                path: "relation/",
                encoding: .URL,
                body: [
                    "friend_pk" : user.id,
                    "relation_type" : type.rawValue,
                    "is_create" : createAction ? "true" : "false"
                ])
            
        case .FollowRequests:
            
            return self.authorizedRequest(.GET,
                                          path: "requests/",
                                          encoding: .URL,
                                          body: [:])
        case .Followers:
            
            return self.authorizedRequest(.GET,
                                          path: "followers/",
                                          encoding: .URL,
                                          body: [:])
            
        case .Following:
            
            return self.authorizedRequest(.GET,
                                          path: "followings/",
                                          encoding: .URL,
                                          body: [:])
            
        }
    }
}