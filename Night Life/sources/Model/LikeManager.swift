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
    
    static var arrayOfLikes : [Report] = []
    
    static func appendLikeDislike(report : Report, valueOfSwitch : Bool){
        
        guard valueOfSwitch else {
            
            arrayOfLikes = arrayOfLikes
                .filter{ (value) -> Bool in
                value.id != report.id
            }
            
            print(arrayOfLikes)
            
            return
        }

        arrayOfLikes.append(report)
        print(arrayOfLikes)

    }
    
    static func containsReport (report : Report) -> Bool {
        return arrayOfLikes.contains({ $0.id == report.id })
    }
    
    static func changer() -> [FeedDataItem] {
        return arrayOfLikes.map({ (report) -> FeedDataItem in
            return .ReportType(report: report)
        })
    }
    
}

struct LikeProvider :  FeedDataProvider {
    
    func loadBatch(batch: Batch) -> Observable<[FeedDataItem]>{
        print("Hi!!!")
        return Observable.just(LikeManager.changer())
    }
    
}
