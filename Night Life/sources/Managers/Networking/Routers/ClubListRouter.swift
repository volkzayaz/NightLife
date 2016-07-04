//
//  CkubListRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import CoreLocation

enum ClubListRouter : AuthorizedRouter {
    
    case InCity(city: City?)
    case Liked
    case Nearest(location: CLLocation)
    
}

extension ClubListRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self {
            
        case .InCity(let city):
            
            var body = [
                "latitude" : 0,
                "longitude" : 0
            ]
            
            if let c = city {
                body["filter_city"] = c.id
            }
            
            return self.authorizedRequest(.GET,
                path: "places/",
                encoding: .URL,
                body: body)
            
        case .Liked:
            
            return self.authorizedRequest(.GET,
                path: "places/saved/",
                encoding: .URL,
                body: [:])
            
        case .Nearest(let location):
            
            return self.authorizedRequest(.GET,
                                          path: "places/nearest/",
                                          encoding: .URL,
                                          body: [
                                            "latitude" : location.coordinate.latitude,
                                            "longitude" : location.coordinate.longitude
                ])
            
            
        }
    }
    
}