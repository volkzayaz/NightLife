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
    
    let id : Int
    let body : String
    let createdDate : NSDate?
    let createdDayOfWeek: String
    
    init(body : String, createdDayOfWeek : String, createdDate : NSDate? = nil)  {
       
        self.body = body
        self.id = Int(arc4random_uniform(200)) //TODO Int.max
        self.createdDate = createdDate
        self.createdDayOfWeek = createdDayOfWeek
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

