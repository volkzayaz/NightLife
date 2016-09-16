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
    var comments : Variable<[Comment]>?
    var message : Message
    //var comment : Comment
   
    private let bag = DisposeBag()
    
    init (message : Message) {
    
        self.message = message
        
//        InMemoryStorageArray.recieveCommentsByMessage(message.id).asObservable()
//            .subscribeNext { (comments : [Comment]) in
//                
//            self.comments!.value = comments
//                
//        }.addDisposableTo(bag)
//
//        guard self.comments != nil else {
//            displayData = nil
//            return }
        print("CommentViewModel init")
        displayData = InMemoryStorageArray.recieveCommentsByMessage(message.id).asDriver()
            .map {[CommentSection(items: $0 ) ]}
     
    }

    
    func createComment(body : String) {
        
        InMemoryStorageArray.saveComment(message.id, body : body)
        
    }
    


        
        
    func deleteComment(row: Int) {
        
        
//            let message = MessagesContext.messages.value[row]
//            InMemoryStorageArray.storage[message.id]?.value[]
        
        }
        
}

    
    

