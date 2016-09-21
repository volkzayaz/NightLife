//
//  MessagesViewModel.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift

import Alamofire
import RxAlamofire

struct MessageViewModel {
    
    var message : Message

    private let bag = DisposeBag()
    
    init(message: Message) {
        self.message = message
        
        if !message.isRead {
            Alamofire.request(MessagesRouter.MarkRead(message: message))
                .rx_responseJSON()
                .subscribeNext { _ in
                    self.message.isRead = true
                    self.message.saveEntity()
                }
                .addDisposableTo(bag)
        }
    }
    
    

    let savedComment : Variable<String> = Variable("")
    var commentObservable : Observable <String>? {
  
        
        didSet {
            commentObservable!
                .flatMap { (comment :String) -> Observable <String> in
         print("commentObservable")              
                    print(comment)
                    return Observable.just("")
            }
                .subscribeNext { (comment : String) in
                self.savedComment.value = comment
            }
        }
        
    }

    
    
    
    func saveComment(textComment : String) {
        
        print ("MessageViewModel = \(self.message.id)" )
        CommentStorage.saveMessageComments(self.message, textComment: textComment)
        
    }
    
}
