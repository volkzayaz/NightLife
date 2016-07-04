//
//  TodayDayManager.swift
//  GlobBar
//
//  Created by admin on 22.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

//class TodayDayManager: NSObject {
//
//}

struct TodayDayManager {

    /**
     * Day of the week as string
     */
    static func dayOfWeekText() -> String {
        
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE"
            
            return dateFormatter.stringFromDate(NSDate())
    }
}