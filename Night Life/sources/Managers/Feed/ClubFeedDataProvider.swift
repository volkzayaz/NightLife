//
//  ClubFeedDataProvider.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/2/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import RxDataSources
import Alamofire
import RxAlamofire

import ObjectMapper

struct ClubFeedDataProvider {
    
    let club: Club
    let filter: FeedFilter
    
    init(club: Club, filter: FeedFilter) {
        self.club = club
        self.filter = filter
    }
    
}

extension ClubFeedDataProvider : FeedDataProvider {
    
    func loadBatch(batch: Batch) -> Observable<[FeedDataItem]> {
        
        let rout = FeedDisplayableRouter.FeedOfClub(club: club, filter: filter, batch: batch)
        
        return Alamofire.request(rout)
            .rx_responseJSON()
            .map { response -> [FeedDataItem] in
                
                guard let rootJSON = response.1 as? [String : AnyObject],
                      let reportsJSON = rootJSON["reports"] as? [[String : AnyObject]],
                      let users = Mapper<User>().mapArray(reportsJSON.map ({ $0["owner"] as! [String : AnyObject] })) else {
                
                        ///this should never happen in app lifecycle
                        assert(false, "error recognizing server response structure")
                        return []
                }
                
                users.forEach { user in
                    ///FIXME: get away from heruistic on merging entities
                    if user != User.currentUser() {
                        user.saveEntity()
                    }
                }
                
                return reportsJSON.map { FeedDataItem(feedItemJSON: $0)! }
        }

        
        
    }
    
}

extension FeedDataItem : IdentifiableType, RawRepresentable, Equatable {
    typealias Identity = String
    
    var identity: String {
        return self.rawValue
    }
    
    typealias RawValue = String
    init?(rawValue: RawValue) {
        return nil
    }
    
    var rawValue: RawValue {
        switch self {
        case .MediaType(let media):
            return "media \(media.id)"
        case .ReportType(let report):
            return "report \(report.id)"
        }
    }
}

// equatable, this is needed to detect changes
func == (lhs: FeedDataItem, rhs: FeedDataItem) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

