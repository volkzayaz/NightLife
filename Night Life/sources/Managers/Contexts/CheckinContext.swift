//
//  CheckinContext.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/14/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

class CheckinContext {
    
    typealias Checkin = (clubId: Int, dueDate: NSDate)
    
    private static var checkins : [Checkin] = []
    
    class func drainAllCheckins() {
        checkins.removeAll()
    }
    
    class func registerCheckinInClub(club: Club, dueDate date:NSDate) {
        
        if let index = checkins.indexOf({ $0.clubId == club.id }) {
            checkins.removeAtIndex(index)
        }
        
        checkins.append((club.id, date))
    }

    class func isUserChekedInClub(club: Club) -> Bool {
        
        return checkins.indexOf({
                $0.clubId == club.id &&
                $0.dueDate.compare(NSDate()) == .OrderedDescending
        }) != nil
        
    }
    
}