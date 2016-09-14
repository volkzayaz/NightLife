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
    
    let displayData: Driver<[MessageSection]>
    let detailMessageViewModel: Variable<MessageViewModel?> = Variable(nil)
    
    private let bag = DisposeBag()

    //var sections : Variable<[SectionOfData]> = Variable([])

   
    init() {
        
        Comment.storage
            .map { (tuple : (Int, Variable<Comment>)) -> Observable<Comment>  in
                return tuple.1.asObservable()
            }
            .combineLatest { $0 }
            .flatMap { _ in
                
                return Message.storage
            }
            .map { (messages : [Message]) -> [MessageSection] in
                
                let a : [Message] = messages.filter{ (message : Message) -> Comment in
                    
                    return (Comment.storage[message.id].value)
                }
                
                let b : [MessageSection] = a.map { (message : Message) -> ViewModelCell in
                    
                    return ViewModelCell(album: album)
                }
                
                return b
            }
            
            .map{ (cells : [MessageSection]) -> [SectionOfData] in
                
                return [SectionOfData (header : "Commented messages", items : cells)]
                
            }
            .subscribeNext { (sections: [SectionOfData]) in
                
                self.sections.value = sections
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

    