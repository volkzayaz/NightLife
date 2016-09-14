//
//  LikeManager.swift
//  GlobBar
//
//  Created by Andrew Seregin on 9/14/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift

class LikeManager {
    
    
    static var arrayOfLikes : Variable<[Int]> = Variable([])
    
    static func appendLikeDislike(reportId : Int, valueOfSwitch : Bool){
        
        guard valueOfSwitch else {
            
            arrayOfLikes.value = arrayOfLikes.value
                .filter{ (value) -> Bool in
                value != reportId
            }
            
            return
        }
        
        arrayOfLikes.value.append(reportId)
    }
}