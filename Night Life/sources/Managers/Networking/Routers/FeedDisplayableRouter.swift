//
//  FeedDisplayableRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/26/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import ObjectMapper

enum FeedDisplayableRouter: AuthorizedRouter {
    
    case CreateReportForClub(report: Report, club: Club)
    
    case UploadPhoto
    case UploadVideo
    
    case FeedOfClub(club: Club, filter: FeedFilter, batch: Batch)
    case FeedOfCity(city: City, filter: FeedFilter, batch: Batch)
    
    case LikeMedia(media: MediaItem)
 
    case UpdateMediaDescription
    
    case DeleteMedia(media: MediaItem)
}

extension FeedDisplayableRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self {
        
        case .CreateReportForClub(let report, let club):
            
            var reportJSON = Mapper().toJSON(report)
            reportJSON["place"] = club.id
            
            let request = self.authorizedRequest(.POST,
                path: "report/",
                encoding: .JSON,
                body: reportJSON
            )
            
            return request
            
        case .FeedOfClub(let club, let filter, let batch):

            return self.authorizedRequest(.GET,
                path: "places/\(club.id)/",
                encoding: .URL,
                body: [
                    "limit_from" : batch.offset,
                    "limit_count" : batch.limit,
                    "period_filter" : filter.serverString()
                ])
        
        case .FeedOfCity(let city, let filter, let batch):
            
            return self.authorizedRequest(.GET,
                path: "city_reports/",
                encoding: .URL,
                body: [
                    "filter_city" : city.id,
                    "limit_from" : batch.offset,
                    "limit_count" : batch.limit,
                    "period_filter" : filter.serverString()
                ])
            
        case .LikeMedia(let media):
            
            return self.authorizedRequest(.POST,
                                          path: "report/image/like/",
                                          encoding: .URL,
                                          body: ["report_pk" : media.id])
            
        case .UploadVideo:
            
            return self.authorizedRequest(.POST,
                                          path: "report/videos/",
                                          encoding: .URL,
                                          body: [:])
            
        case .UploadPhoto:
            
            return self.authorizedRequest(.POST,
                                          path: "report/files/",
                                          encoding: .URL,
                                          body:[:])
            
        case .UpdateMediaDescription:
            
            return self.authorizedRequest(.PUT,
                                          path: "report/files/",
                                          encoding: .URL,
                                          body: [:])
            
        case .DeleteMedia(let media):
            
            return self.authorizedRequest(.DELETE,
                                          path: "report/",
                                          encoding:  .URL,
                                          body: [ "report_pk" : media.id ])
            
            
        }
        
    }
    
}