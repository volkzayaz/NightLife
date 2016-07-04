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
}
