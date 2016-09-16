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
    var comments : [Comment]?
    
    private let bag = DisposeBag()
    
    init(message: Message, comments : [Comment]) {
        self.message = message
        self.comments = comments
        
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
    
    init(message: Message) {
        self.message = message
        self.comments = nil
        
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

}
