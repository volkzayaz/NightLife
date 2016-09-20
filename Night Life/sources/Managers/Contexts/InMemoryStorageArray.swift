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
 
    static func recieveCommentsByMessage (message : Message) -> Variable<[Comment]> {
        
        guard let comments = storage[message.id] else { fatalError("Comments cannot be nil, at least one element is necessary" ) }
        return comments    
    }
    

    static func saveCommentByMessage(message : Message, body : String) {
        
        if self.storage[message.id] == nil {
            self.storage[message.id] = Variable([])
        }
        guard body.characters.count > 1  else { return }
        self.storage[message.id]!.value.append(Comment(body : body, createdDayOfWeek : TodayDayManager.dayOfWeekText(), createdDate : NSDate()))
       
    }
    
    static func removeCommentFromStorage(message : Message, row: Int) {
        self.storage[message.id]?.value.removeAtIndex(row)
   
    }    
    
    static func removeAllCommentsFromStorageByMessage(message : Message) {
        storage.removeValueForKey(message.id)
    }



}
