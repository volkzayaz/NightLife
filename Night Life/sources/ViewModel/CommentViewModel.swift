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
    
    var displayData: Driver<[CommentSection]>?
   
    var message : Message
    private let bag = DisposeBag()
    
    var commentCountObservable : Observable<Int> {
        print(InMemoryStorageArray.recieveCommentsByMessage(self.message.id).value.count)
        return Observable.just(InMemoryStorageArray.recieveCommentsByMessage(self.message.id).value.count)
    
    }
    
    init (message : Message) {
    
        self.message = message
    
        displayData = InMemoryStorageArray.recieveCommentsByMessage(message.id).asDriver()
            .map {[CommentSection(items: $0 ) ]}
    }

    
    func createComment(body : String) -> [Comment] {
        
        InMemoryStorageArray.saveComment(message.id, body : body)
        return (InMemoryStorageArray.storage[message.id]?.value)!
    }
    


        
        
    func deleteComment(row: Int) {
        InMemoryStorageArray.removeCommentFromStorage(message.id, row: row)        
    }
        
}

    
    

