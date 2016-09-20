//
//  MessageListViewModel.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire
import ObjectMapper


enum MessageListError : ErrorType {

    case MalformedServerResponse
}

class MessageListViewModel {
    
    let displayData: Driver<[MessageSection]>
    let detailMessageViewModel: Variable<MessageViewModel?> = Variable(nil)
   
    
    private let bag = DisposeBag()
    
    init() {
        
        displayData = MessagesContext.messages.asDriver()
            .map { [ MessageSection(items: $0 ) ] }
        
        MessagesContext.refreshMessages()
            .addDisposableTo(bag)
        
    }
}

extension MessageListViewModel {
    
    func selectedMessage(atIndexPath ip: NSIndexPath) {
        
        let message = MessagesContext.messages.value[ip.row]
        
        if InMemoryStorageArray.storage[message.id] == nil {
            InMemoryStorageArray.storage[message.id] = Variable([])
            InMemoryStorageArray.storage[message.id]!.value.append(Comment(messageId: message.id, body : "", created : "", createdDate : nil))
        }
        
        detailMessageViewModel.value = MessageViewModel(message: message)
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