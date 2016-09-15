//
//  ViewModelCell.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 15.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//
import Foundation
import RxCocoa
import RxSwift
import RxDataSources

struct ViewModelCell {
    
    private(set) var message : Message
    //private(set) var user : User? = nil
    
   // private let apiServiceGet = ApiServiceGet()
    var bag = DisposeBag()
    
    var commentObservable: Observable<Comment> {
        
        return Comment.storage[message.id]!.asObservable()
    }
    
 //   func saveComment (comment : Comment) {
     //
     //   Comment.saveEntity(comment)
    //}
    
    
    init(message : Message) {
    
    
    self.message = message
    
    }
    
    
    }


extension ViewModelCell : Hashable, IdentifiableType, Equatable  {
    
    
    var hashValue : Int {
        get {
            return self.message.id.hashValue
        }
    }
    
    var identity: String {
        
        return message.title
        
    }
    
}

func ==(lhs: ViewModelCell, rhs: ViewModelCell) -> Bool {
    
    return lhs.message == rhs.message

}
