//
//  CommentViewModel.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 14.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

struct CommentViewModel {
    
    let displayData: Driver<[CommentSection]>?
   
    private let message : Message
    private let bag = DisposeBag()
    
    init (message : Message) {
    
        self.message = message
    
        displayData = InMemoryStorageArray.storage[self.message.id]!.asDriver()
            .map {[CommentSection(items: $0 ) ]}
    }

    
    var commentCountObservable : Observable<Int> {
        
        return Observable.just(InMemoryStorageArray.storage[self.message.id]!.value.count)
        
    }

    func createComment(body : String) -> [Comment] {
        
        
        
        InMemoryStorageArray.saveCommentByMessage(message, body : body)
        return (InMemoryStorageArray.storage[message.id]!.value)
    }
    
  
    func deleteComment(row: Int) {
        InMemoryStorageArray.removeCommentFromStorage(message, row: row)        
    }
        
}

    
    

