//
//  CommentedMessageListViewModel.swift
//  GlobBar
//
//  Created by Administrator on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources


class CommentedMessageListViewModel {
    
    private let bag = DisposeBag()
    var sections : Variable<[CommentedMessageSection]> = Variable([])
    let detailsCommentedMessage : Variable<MessageViewModel?> = Variable(nil)
    
    
    init () {
        
        CommentStorage.getCommentedMessages()
            .map { (messages : [Message]) -> [CellViewModel] in
                return messages.map{ (message : Message) -> CellViewModel in
                    return CellViewModel(message : message)
            }
        }
            .map { (cells: [CellViewModel]) -> [CommentedMessageSection] in
                return [CommentedMessageSection(header : "Commented Messagess", items: cells)]
            }
            .subscribeNext { (sections : [CommentedMessageSection]) in
            self.sections.value = sections
        }
        .addDisposableTo(bag)
    }
    

    
    func selectedCommentedMessage(atIndexPath indexPath: NSIndexPath) {
  
        print ("CommentedMessageListViewModel = \(indexPath.row)")
//        self.sections.asObservable().
//        let commentedMessage = sections.value.

        
        let message = MessagesContext.messages.value[indexPath.row]
        detailsCommentedMessage.value = MessageViewModel(message: message)
    }

    
    
}