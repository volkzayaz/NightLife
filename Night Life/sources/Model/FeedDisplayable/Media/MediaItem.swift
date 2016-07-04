//
//  Photo.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/1/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

enum MediaItemType: Int {
    case Photo = 1
    case Video = 2
}

final class MediaItem : FeedDisplayable, Storable {
    
    var identifier: Int { return id }
    
    private(set) var thumbnailURL: String = ""
    private(set) var mediaURL: String = ""
    var mediaDescription: String = ""
    
    private(set) var isHot: Bool = false
    var likesCount: Int = 0
    
    private(set) var isLikedByCurrentUser: Bool = false
    
    private(set) var type: MediaItemType!
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        type <- map["type"]
        
        thumbnailURL <- map["thumbnail"]
        mediaURL <- map["report_media"]
        mediaDescription <- map["description"]
        
        likesCount <- map["like_cnt"]
        isHot <- map["is_hot"]
        
        isLikedByCurrentUser <- map["is_liked"]
        
        
    }
    
    func setLikeStatusOn() {
        
        likesCount += 1
        isLikedByCurrentUser = true
        
    }
}
