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
   // var comments : Variable<[Comment]>?
    var message : Message
   
   
    private let bag = DisposeBag()
    
    init (message : Message) {
    
        self.message = message

        displayData = InMemoryStorageArray.recieveCommentsByMessage(message.id).asDriver()
            .map {[CommentSection(items: $0 ) ]}
            
     
    }

    
    func createComment(body : String) -> [Comment] {
        
        InMemoryStorageArray.saveComment(message.id, body : body)
        
        print("InMemoryStorageArray.recieveCommentsByMessage(message.id).value")
        print(InMemoryStorageArray.recieveCommentsByMessage(message.id).value)
        
        return InMemoryStorageArray.recieveCommentsByMessage(message.id).value
    }
    


        
        
    func deleteComment(row: Int) {
        
        
        InMemoryStorageArray.removeCommentFromStorage(message.id, row: row)
        
        }
        
}

    
    

