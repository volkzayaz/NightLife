////
////  CommentListViewModel.swift
////  GlobBar
////
////  Created by Anna Gorobchenko on 14.09.16.
////  Copyright © 2016 com.NightLife. All rights reserved.
////
//
import RxSwift
import RxCocoa
import RxDataSources
import Alamofire
import RxAlamofire
import ObjectMapper


struct CommentedMessagesListViewModel {
    
    var displayData: Variable<[CommentedMessageSection]> = Variable([])
    let detailMessageViewModel: Variable<MessageViewModel?> = Variable(nil)
    
    private let bag = DisposeBag()

    
    
    init() {
        
        
        let commentedMessages = MessagesContext.messages
                .asObservable()
                .flatMapLatest { messages -> Observable<[Message]> in
                    messages /// all messages
                        .flatMap { ///filtering out messages that are not commented
                            $0.observableEntity()?.asObservable() /// getting observable message from storage
                        }
                        .combineLatest { commentedMessages in ///mapping true messages to unread counter
                            let a = commentedMessages.filter { Comment.storage[$0.id] != nil }

                            return a
                            
                        }
                    
            }

        
        commentedMessages.map { (messages : [Message]) -> [ViewModelCell] in

                    let b : [ViewModelCell] = messages.map { (message : Message) -> ViewModelCell in
                        return ViewModelCell(message: message)
                    }
    
                    return b
                }.map { (cells : [ViewModelCell]) -> [CommentedMessageSection] in
    
                    return [CommentedMessageSection (header : "Commented messages", items : cells)]
    
                }
                .subscribeNext { (sections: [CommentedMessageSection]) in
    
                    self.displayData.value = sections
                }
                .addDisposableTo(bag)
        
        }
        
        
    }
    
        

        




extension CommentedMessagesListViewModel {
    
    func selectedMessage(atIndexPath ip: NSIndexPath) {
        let message = MessagesContext.messages.value[ip.row]
        let comment = Comment.entityByIdentifier(message.id)
        
        detailMessageViewModel.value = MessageViewModel(message: message, comment : comment!)
    }
    
    func deleteMessage(row: Int) {
        
        let message = MessagesContext.messages.value[row]
        let comment = Comment.entityByIdentifier(message.id)
        
        message.removeFromStorage()
        comment!.removeFromStorage()
        
        
        MessagesContext.messages.value.removeAtIndex(row)
        
        Alamofire.request(MessagesRouter.Delete(message: message)).rx_responseJSON()
            .subscribeError { error in
                print("delete message from server error: \(error)")
            }
            .addDisposableTo(bag)
    }
    
}

