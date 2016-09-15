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
                    messages
                        .flatMap {
                            $0.observableEntity()?.asObservable()
                        }
                        .combineLatest { commentedMessages in
                            let commentedMessages : [Message] = commentedMessages.filter { Comment.storage[$0.id] != nil }
                            return commentedMessages
                        }
            }

        
        commentedMessages.map { (messages : [Message]) -> [ViewModelCell] in

                    let viewModelCell : [ViewModelCell] = messages.map { (message : Message) -> ViewModelCell in
                        return ViewModelCell(message: message)
                    }
    
                    return viewModelCell
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
        
        guard let a = comment else {
            
            return detailMessageViewModel.value = MessageViewModel(message: message)
        }
        detailMessageViewModel.value = MessageViewModel(message: message, comment : a)
      
        
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

