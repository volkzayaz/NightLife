////
////  InMemoryStorageArray.swift
////  GlobBar
////
////  Created by Anna Gorobchenko on 16.09.16.
////  Copyright © 2016 com.NightLife. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa


struct InMemoryStorageArray {

    static var storage: [Int : Variable<[Comment]>] = [ : ]    
 
    static func recieveCommentsByMessage (key : Int) -> Variable<[Comment]> {
        
        guard let comments = storage[key] else { fatalError("Comments cannot be nil, at least one element is necessary" ) }
        return comments    
    }
    

    static func saveComment(key : Int, body : String) {
        
        if self.storage[key] == nil {
            self.storage[key] = Variable([])
        }
        guard body.characters.count > 1  else { return }
        self.storage[key]!.value.append(Comment(messageId: key, body : body, created : TodayDayManager.dayOfWeekText(), createdDate : NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle) ))
       
    }
    
    static func removeCommentFromStorage(key: Int, row: Int) {        
        self.storage[key]?.value.removeAtIndex(row)
   
    }    
    
    static func removeAllCommentsFromStorageByMessage(key : Int) {
        storage.removeValueForKey(key)
    }



}
