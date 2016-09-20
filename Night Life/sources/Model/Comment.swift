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
    
    private(set) var id : Int
    var messageId : Int
    var body : String
    var createdDate : NSDate?
    var created: String
    
    init(messageId : Int, body : String, created : String, createdDate : NSDate? = nil)  {
       
        self.messageId = messageId
        self.body = body
        self.id = Int(arc4random_uniform(200)) //TODO Int.max
        self.createdDate = createdDate
        self.created = created
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

