//
//  PointsRouter.swift
//  Night Life
//
//  Created by admin on 04.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import Alamofire
import RxAlamofire

import ObjectMapper

enum PointsRouter: AuthorizedRouter {

    case GetPoints
    case RemovePoints(points: Int)
}

extension PointsRouter {
    
    var URLRequest: NSMutableURLRequest {
        
        switch self{
            
        case .GetPoints:
            
            return self.authorizedRequest(.GET,
                                          path: "points/",
                                          encoding: .URL,
                                          body: [:])
            
        case .RemovePoints(let points):
            
            return self.authorizedRequest(.POST,
                                          path: "points/",
                                          encoding: .URL,
                                          body: ["spent_points" : points])
        }
    }
}