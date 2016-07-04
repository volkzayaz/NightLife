//
//  FeedDisplayable.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

class FeedDisplayable : Mappable {
    
    private(set) var id: Int = 0
    
    var postOwnerId: Int = 0
    private(set) var createdDate: NSDate?
    
    ///which club this report belongs to
    private(set) var clubId: Int?
    
    init(postOwner: User, createdDate: NSDate) {
        
        self.postOwnerId = postOwner.id
        self.createdDate = createdDate
        
    }
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        
        postOwnerId <- map["owner.pk"]
        
        createdDate <- (map["created"], ISO8601DateTransform())
        id <- map["pk"]
        
        clubId <- map["place"]
    }
 
}


enum FeedDataItem {
    
    case MediaType(media: MediaItem)
    case ReportType(report: Report)
    
    init?(feedItemJSON: [String: AnyObject], postOwner: User? = nil) {
        
        guard let type = feedItemJSON["type"] as? Int else {
            assert(false, "Can't create FeedDataItem without 'type' in dictionary")
            return nil
        }
        
        switch type {
        case 0:
            let mapper = Mapper<Report>()
            guard let report = mapper.map(feedItemJSON) else {
                assert(false, "Error parsing report object")
                return nil
            }
            
            if let user = postOwner { report.postOwnerId = user.id }
            
            self = .ReportType(report: report)
            
        case 1, 2:
            let mapper = Mapper<MediaItem>()
            guard let media = mapper.map(feedItemJSON) else {
                assert(false, "Error parsing report object")
                return nil
            }
            
            if let user = postOwner { media.postOwnerId = user.id }
            
            self = .MediaType(media: media)
            media.saveEntity()
            
            
        default:
            fatalError("type of FeedData item \(type) is not handled")
        }
        
        
        
    }
    
}