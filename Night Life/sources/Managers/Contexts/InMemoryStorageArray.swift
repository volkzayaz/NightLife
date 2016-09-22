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
import CoreLocation

struct InMemoryStorageArray {

    static let bag = DisposeBag()
    
    static var storage: [Int : Variable<[Comment]>] = [ : ]
 
    static func recieveCommentsByMessage (message : Message) -> Variable<[Comment]> {
        
        guard let comments = storage[message.id] else { fatalError("Comments cannot be nil, at least one element is necessary" ) }
        return comments    
    }
    

    static func saveCommentByMessage(message : Message, body : String) {        
        
        guard body.characters.count > 1  else { return }
        
        _ = LocationManager.instance.lastRecordedLocationObservable
            .take(1)
            .subscribe(
                onNext : { location in
                   self.storage[message.id]!.value.append(Comment(body : body,messageId: message.id, createdDate : NSDate(), location : location))
                }
                
            ).addDisposableTo(bag)

        
       
    }
    
    static func removeCommentFromStorage(message : Message, row: Int) {
        self.storage[message.id]?.value.removeAtIndex(row)
   
    }    
    
    static func removeAllCommentsFromStorageByMessage(message : Message) {
        storage.removeValueForKey(message.id)
    }



}
