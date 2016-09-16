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
    
    static var arrayOfLikes : Variable<[Report]> = Variable([])
    
    static func appendLikeDislike(report : Report, valueOfSwitch : Bool){
        
        guard valueOfSwitch else {
            
            arrayOfLikes.value = arrayOfLikes.value
                .filter{ (value) -> Bool in
                value.id != report.id
            }
            
            print(arrayOfLikes.value)
            
            return
        }

        arrayOfLikes.value.append(report)
        print(arrayOfLikes.value)

    }
    
    static func containsReport (report : Report) -> Bool {
        return arrayOfLikes.value.contains({ $0.id == report.id })
    }
    
    static func changer(array : [Report]) -> [FeedDataItem] {
        return array.map({ (report) -> FeedDataItem in
            return .ReportType(report: report)
        })
    }
    
}

struct LikeProvider :  FeedDataProvider {
    
    func loadBatch(batch: Batch) -> Observable<[FeedDataItem]>{
        
        return LikeManager.arrayOfLikes.asObservable()
            .map{ (reports : [Report]) -> [FeedDataItem] in
                return reports.map{ (report : Report) -> FeedDataItem in
                    return .ReportType(report: report)
                }
        }.filter{ (array) -> Bool in
            return array.count > batch.offset
        }
    }
    
}
