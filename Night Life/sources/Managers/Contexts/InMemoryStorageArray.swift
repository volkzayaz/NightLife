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
 
    static func recieveCommentsByMessage (messageIdentificator : Int) -> Variable<[Comment]> {
        
        guard let comments = storage[messageIdentificator] else { fatalError("Comments cannot be nil, at least one element is necessary" ) }
        return comments    
    }
    

    static func saveCommentByMessage(messageIdentificator : Int, body : String) {
        
        if self.storage[messageIdentificator] == nil {
            self.storage[messageIdentificator] = Variable([])
        }
        guard body.characters.count > 1  else { return }
        self.storage[messageIdentificator]!.value.append(Comment(messageId: messageIdentificator, body : body, created : TodayDayManager.dayOfWeekText(), createdDate : NSDate()))
       
    }
    
    static func removeCommentFromStorage(messageIdentificator: Int, row: Int) {
        self.storage[messageIdentificator]?.value.removeAtIndex(row)
   
    }    
    
    static func removeAllCommentsFromStorageByMessage(messageIdentificator : Int) {
        storage.removeValueForKey(messageIdentificator)
    }



}
