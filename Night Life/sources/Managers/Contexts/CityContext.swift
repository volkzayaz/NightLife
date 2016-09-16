//
//  CityContext.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire
import ObjectMapper

class CityContext {
    
    static let selectedCity: Variable<City?> = Variable(nil)
    
}



class MessagesContext {
    
    static let messages: Variable<[Message]> = Variable([])    
  
    
    static func refreshMessages() -> Disposable {
        
        return Alamofire
            .request(MessagesRouter.List).rx_responseJSON()
            .flatMap { response -> Observable<[Message]> in
                
                let messageMapper : Mapper<Message> = Mapper()
                
                guard let rootJSON = response.1 as? [AnyObject],
                    let messages = messageMapper.mapArray(rootJSON) else {
                        return Observable.error(MessageListError.MalformedServerResponse)
                }
                
                ///stroing it into storage
                messages.forEach { $0.saveEntity() }
                
                return Observable.just( messages )
            }
            .bindTo(messages)
        
    }
    
}




