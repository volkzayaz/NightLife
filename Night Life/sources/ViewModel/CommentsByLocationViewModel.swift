//
//  CommentsByLocationViewModel.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import Alamofire
import RxAlamofire
import ObjectMapper

struct CommentsByLocationViewModel {
    
    var displayData: Variable<[CommentsSection]> = Variable([])
   // let detailMessageViewModel: Variable<MessageViewModel?> = Variable(nil)
    
    private let bag = DisposeBag()
    
    
    
    init() {
        
        
        let commentedMessages = MessagesContext.messages
            .asObservable()
            .flatMapLatest { (messages : [Message]) -> Observable<[Message]> in
                messages
                    .flatMap { (message : Message) in
                        message.observableEntity()?.asObservable()
                    }
                    .combineLatest { commentedMessages in
                        
                        let commentedMessages : [Message] = commentedMessages.filter { InMemoryStorageArray.storage[$0.id]?.value.count > 0
                            
                        }
                        
                        return commentedMessages
                }
        }
        
        
        let commentsLocated = commentedMessages.map { (messages : [Message]) -> [Comment] in
            return messages.flatMap { (message : Message) -> [Comment] in
                return (InMemoryStorageArray.storage[message.id]?.value)!
            }
           
        }
        
            
//        let sortedComments = commentsLocated.map{ (comments : [Comment]) -> [Comment] in
//          
//           return comments.sort{ $0.0.location == $0.1.location }
//
//        }
        
        commentsLocated.map { (comments : [Comment]) -> [ViewModelCommentCell] in
            
            
            let viewModelCommentCells : [ViewModelCommentCell] = comments.map { (comment : Comment) -> ViewModelCommentCell in
                return ViewModelCommentCell(comment: comment)
            }
            
            return viewModelCommentCells
            }.map { (cells : [ViewModelCommentCell]) -> [CommentsSection] in
                let a = cells.sort{ $0.0.comment.location == $0.1.comment.location }
                
                return [CommentsSection (header : "Comments", items : a)]
            }
            .subscribeNext { (sections: [CommentsSection]) in
                self.displayData.value = sections
            }
            .addDisposableTo(bag)
        
    }
    
    
}



extension CommentsByLocationViewModel {
    
    func selectedComment(atIndexPath ip: NSIndexPath) {
//        let message = displayData.value.first?.items[ip.row].message
//        detailMessageViewModel.value = MessageViewModel(message: message!)
        
    }
    
    func deleteComment(row: Int) {
        
        let comment = displayData.value.first?.items[row].comment
        
        let index = InMemoryStorageArray.storage[comment!.messageId]?.value.indexOf(comment!)
        
        print(index)
        
        InMemoryStorageArray.storage[comment!.messageId]?.value.removeAtIndex(index!)
        
    }
//        message!.removeFromStorage()
//        InMemoryStorageArray.removeAllCommentsFromStorageByMessage(message!)
//        
//        MessagesContext.messages.value.removeAtIndex(row)
//        
//        Alamofire.request(MessagesRouter.Delete(message: message!)).rx_responseJSON()
//            .subscribeError { error in
//                print("delete message from server error: \(error)")
//            }
//            .addDisposableTo(bag)
    
    
}

