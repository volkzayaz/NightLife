//
//  Report.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

class Report : FeedDisplayable {
    
    private(set) var partyOnStatus: PartyStatus?
    private(set) var fullness: Fullness?
    private(set) var musicType: Music?
    private(set) var genderRatio: GenderRatio?
    private(set) var coverCharge: CoverCharge?
    private(set) var queue: QueueLine?
    
    init(partyOnStatus: PartyStatus?, fullness: Fullness?, musicType: Music?, genderRatio: GenderRatio?, coverCharge: CoverCharge?, queue: QueueLine?) {
        
        self.partyOnStatus = partyOnStatus
        self.fullness = fullness
        self.musicType = musicType
        self.genderRatio = genderRatio
        self.coverCharge = coverCharge
        self.queue = queue
        
        super.init(postOwner: User.currentUser()!, createdDate: NSDate())
        
    }
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        partyOnStatus <- (map["is_going"], Report.partyStatusTransform())
        fullness <- map["bar_filling"]
        musicType <- map["music_type"]
        genderRatio <- map["gender_relation"]
        coverCharge <- map["charge"]
        queue <- map["queue"]
    }
    
    static func partyStatusTransform() -> TransformOf<PartyStatus, Bool> {
        return TransformOf(fromJSON: { (bool: Bool?) -> PartyStatus? in
            guard let b = bool else { return nil }
            
            return PartyStatus(bool: b)
            }, toJSON: { (status :PartyStatus?) -> Bool? in
                guard let b = status else { return nil }
                
                return b == .Yes
        })
    }
    
}

extension Report : CustomStringConvertible {
    
    private func stringValue(opts: [CustomStringConvertible?]) -> String {
        var str = ""
        
        for optional in opts {
            if let o = optional {
                str.appendContentsOf(o.description)
            }
        }
        
        return str
    }
    
    var description : String {
        let array: [CustomStringConvertible?] = [partyOnStatus, fullness, musicType, genderRatio, coverCharge, queue]
        return stringValue(array)
    }
    
}

protocol IconProvider {
    func iconName() -> String
}

enum PartyStatus : Int, CustomStringConvertible, IconProvider {
    
    case Yes = 1
    case No
    
    init(bool: Bool) {
        self = bool ? .Yes : .No
    }
    
    var description: String {
        switch self {
        case Yes:
            return "Party is on!"
        case No:
            return "No"
        }
    }
    
    func iconName() -> String {
        return "recommends"
    }
    
}

enum Fullness : Int, CustomStringConvertible, IconProvider {
    case Empty = 1
    case Low
    case Crowded
    case Packed
    
    var description: String {
        switch self {
        case Empty:
            return "Empty"
        case Low:
            return "Slow"
        case Crowded:
            return "Crowded"
        case Packed:
            return "Packed"
        }
    }
    
    func iconName() -> String {
        return "fullness"
    }
    
}

enum Music : Int, CustomStringConvertible, IconProvider {
    
    case NoMusic = 1
    case DJ_EDM_House
    case DJ_disco
    case DJ_hip
    case Pop
    case LiveBand
    case Karaoke
    case Other
    
    var description: String {
        switch self {
        case NoMusic:
            return "None"
        case DJ_EDM_House:
            return "DJ-EDM/House"
        case DJ_disco:
            return "DJ-disco"
        case DJ_hip:
            return "DJ-hip hop"
        case Pop:
            return "DJ-top 40"
        case LiveBand:
            return "Live Band"
        case Karaoke:
            return "Karaoke"
        case Other:
            return "Other"
        }
    }
    
    func iconName() -> String {
        return "music"
    }
    
}

enum GenderRatio : Int, CustomStringConvertible, IconProvider {
    case MostlyGuys = 1
    case MoreGuys
    case Balanced
    case MoreLadies
    case MostlyLadies
    
    var description: String {
        switch self {
        case MostlyGuys:
            return "Mostly Guys"
        case MoreGuys:
            return "More Guys"
        case Balanced:
            return "Balanced"
        case MoreLadies:
            return "More Ladies"
        case MostlyLadies:
            return "Mostly Ladies"
        }
    }
    
    func iconName() -> String {
        return "gender"
    }
    
}

enum CoverCharge : Int, CustomStringConvertible, IconProvider  {
    case Free = 1
    case Small
    case Moderete
    case Big
    
    var description: String {
        switch self {
        case Free:
            return "Free"
        case Small:
            return "1-5$"
        case Moderete:
            return "10$"
        case Big:
            return "Over 10$"
        }
    }
    
    func iconName() -> String {
        return "cover_chardge"
    }
    
}

enum QueueLine : Int, CustomStringConvertible, IconProvider  {
    case NoQueue
    case Short
    case Long
    case Enormous
    
    var description: String {
        switch self {
        case NoQueue:
            return "No line"
        case Short:
            return "Less than 10 people"
        case Long:
            return "Long"
        case Enormous:
            return "Extra long"
        }
    }
    
    func iconName() -> String {
        return "queue"
    }
    
}