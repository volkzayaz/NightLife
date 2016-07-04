//
//  PlacesRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/23/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import CoreLocation

enum PlacesRouter : AuthorizedRouter {
    
    /**
     * returns list of cities sorted from closest to furthest based on Location
     */
    case Cities(baseLocation: CLLocation)
    
    case Details(club: Club)
    case Chekin(club: Club, broadcast: Bool)
    
    case Like(club: Club)
    case UnLike(club: Club)

}

extension PlacesRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self{
            
        case .Cities(let baseLocation):
            
            return self.authorizedRequest(.GET,
                path: "cities/",
                encoding: .URL,
                body: [
                    "latitude" : baseLocation.coordinate.latitude,
                    "longitude" : baseLocation.coordinate.longitude
                ])
            
        case .Details(let club):

            return self.authorizedRequest(.GET,
                path: "places/\(club.id)/",
                encoding: .URL,
                body: [:])
            
        case .Chekin(let club, let broadcast):
            
            return self.authorizedRequest(.POST,
                path: "places/checkin/",
                encoding: .URL,
                body: [
                    "place_pk" : club.id,
                    "is_hidden" : broadcast ? "true" : "false"
                ])
            
        case .Like(let club):
            
            return self.authorizedRequest(.POST,
                path: "places/like/",
                encoding: .URL,
                body: ["place_pk" : club.id])
            
        case .UnLike(let club):
            
            return self.authorizedRequest(.POST,
                path: "places/like/",
                encoding: .URL,
                body: [
                    "place_pk" : club.id,
                    "remove_like" : "true"
                ])
            
        }
        
    }
    
}