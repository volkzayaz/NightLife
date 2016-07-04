//
//  ClubsManager.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxSwift
import RxAlamofire
import ObjectMapper

class ClubsManager {
    
    static func clubForId(key: Int, forceRefresh: Bool = false) -> Observable<Club> {
        
        if let club = Club.entityByIdentifier(key) where forceRefresh != true {
            return Observable.just(club)
        }
        
        return Alamofire.request(PlacesRouter.Details(club: Club(id: key)))
            .rx_responseJSON()
            .flatMap { response -> Observable<Club> in
                
                let clubMapper : Mapper<Club> = Mapper()
                
                guard let rootJSON = response.1 as? [String : AnyObject],
                    let clubJSON = rootJSON["place"],
                    let place = clubMapper.map(clubJSON),
                    let usersJSON = clubJSON["last_users"] as? [[String : AnyObject]],
                    let users = Mapper<User>().mapArray( usersJSON ) else {
                
                        return Observable.error(ClubListError.MalformedServerResponse)
                }

                users.forEach { user in
                    if User.entityByIdentifier(user.id) == nil {
                        user.saveEntity()
                    }
                }
                place.saveEntity()

                return Observable.just(place)
            }
        
    }
    
    static func clubListFromRouter(router: ClubListRouter) -> Observable<[Club]> {
        return Alamofire
            .request(router).rx_responseJSON()
            .flatMap { response -> Observable<[Club]> in
                
                guard let rootJSON = response.1 as? [String : AnyObject],
                    let clubsJSON = rootJSON["places"] as? [[String : AnyObject]] else {
                        
                        return Observable.error(ClubListError.MalformedServerResponse)
                }
                
                let clubMapper : Mapper<Club> = Mapper()
                guard let places = clubMapper.mapArray(clubsJSON),
                    let users = Mapper<User>().mapArray(clubsJSON.flatMap ({ $0["last_users"] as! [[String : AnyObject]] }))else {
                        
                        return Observable.error(ClubListError.MalformedServerResponse)
                }
                
                places.forEach { $0.saveEntity() }
                
                users.forEach { user in
                    if User.entityByIdentifier(user.id) == nil {
                        user.saveEntity()
                    }
                }
                
                return Observable.just( places )
        }

    }
    
}