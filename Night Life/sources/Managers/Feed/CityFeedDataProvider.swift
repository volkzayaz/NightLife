//
//  CityFeedDataProvider.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import RxDataSources
import Alamofire
import RxAlamofire

import ObjectMapper

struct CityFeedDataProvider {
    
    let city: City
    let filter: FeedFilter
    
    init(city: City, filter: FeedFilter) {
        self.city = city
        self.filter = filter
    }
    
}

extension CityFeedDataProvider : FeedDataProvider {
    
    func loadBatch(batch: Batch) -> Observable<[FeedDataItem]> {
        
        let rout = FeedDisplayableRouter.FeedOfCity(city: city, filter: filter, batch: batch)
        
        return Alamofire.request(rout)
            .rx_responseJSON()
            .map { response -> [FeedDataItem] in
                
                ///FIXME: parsing response into seperate entities must be encapsulated
                guard let rootJSON = response.1 as? [String : AnyObject], 
                    let clubsJSON = rootJSON["reports"] as? [[String : AnyObject]],
                    let users = Mapper<User>().mapArray(clubsJSON.map ({ $0["owner"] as! [String : AnyObject] }))
                    else {
                        
                        print("Error retreiving reports for city id \(self.city.id)")
                        return []
                }
                
                users.forEach { user in
                    ///FIXME: get away from heruistic on merging entities
                    if user != User.currentUser() {
                        user.saveEntity()
                    }
                }
                
                
                return clubsJSON.map { FeedDataItem(feedItemJSON: $0)! }
        }
        
        
        
    }
    
}
