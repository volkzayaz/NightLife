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
    var detailMessageViewModel: Variable<MessageViewModel?> = Variable(nil)
    
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
                            let commentedMessages : [Message] = commentedMessages.filter { InMemoryStorageArray.storage[$0.id]?.value.count > 1
                              
                            }
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
        let comments : [Comment]? = InMemoryStorageArray.recieveCommentsByMessage(message.id).value
        
        guard let a = comments else {
            
            return detailMessageViewModel.value = MessageViewModel(message: message, comments: nil)
        }
        detailMessageViewModel.value = MessageViewModel(message: message, comments : a)
      
        
    }
    
    func deleteMessage(row: Int) {
        
        let message = MessagesContext.messages.value[row]
        
        message.removeFromStorage()
        InMemoryStorageArray.removeAllCommentsFromStorageByMessage(message.id)
        
        MessagesContext.messages.value.removeAtIndex(row)
        
        Alamofire.request(MessagesRouter.Delete(message: message)).rx_responseJSON()
            .subscribeError { error in
                print("delete message from server error: \(error)")
            }
            .addDisposableTo(bag)
    }
    
}

