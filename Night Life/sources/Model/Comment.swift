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
import CoreLocation

struct Comment  {
    
    let id : Int
    let body : String
    let createdDate : NSDate
    let location : CLLocation?
   
    init(body : String, createdDate : NSDate, location : CLLocation? = nil)  {
       
        self.body = body
        self.id = Int(arc4random_uniform(200)) //TODO Int.max
        self.createdDate = createdDate
        self.location = location

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

