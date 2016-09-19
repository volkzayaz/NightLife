//
//  Comment.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 14.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper
import RxDataSources

struct Comment  {
    
    private(set) var id : Int = 0
    
    var key: Int { return messageId }

    var messageId : Int = 0
    
    var identifier: Int { return id }

    var body : String = ""
    
    //var created: NSDate? //ISO8601DateTransform())
    
    var created: String?
    
    init(messageId : Int, body : String, created : String )  {
    
        self.messageId = messageId
        self.body = body
        self.created = created
        self.id = Int(arc4random_uniform(200)) //TODO Int.max
        
    }
  
}

extension Comment : IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Int {
        return id
    }
    
}

func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.id == rhs.id
}