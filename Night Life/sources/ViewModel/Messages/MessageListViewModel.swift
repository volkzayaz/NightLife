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