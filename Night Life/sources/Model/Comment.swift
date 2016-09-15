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

struct Comment : Storable {
    
    private(set) var id : Int = 0
    
    var messageId : Int = 0
    
    var identifier: Int { return messageId }
    
    //var title : String = ""
    var body : String = ""
    
    //var created: NSDate? //ISO8601DateTransform())
    
 
    init( messageId : Int )  {
    
        self.messageId = messageId
        
    
    
    }
  
}

extension Comment : IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Int {
        return messageId
    }
    
}

func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.id == rhs.id
}