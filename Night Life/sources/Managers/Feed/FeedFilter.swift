//
//  FeedFilter.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

enum FeedFilter: Int {
    
    case Today = 0
    case LastWeek
    case LastMonth
    
    func serverString() -> String {
        switch self {
        case .Today:
            return "today"
        case .LastWeek:
            return "week"
        case .LastMonth:
            return "month"
        }
    }
    
}