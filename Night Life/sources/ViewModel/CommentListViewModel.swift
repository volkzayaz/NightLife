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

//}.combineLatest { (arrayOfLikes : [(Int, Bool)]) -> [Int] in
//    
//    
//    let array =  arrayOfLikes.filter { tuple in tuple.1 }
//        .map { tuple in tuple.0 }
//    
//    guard !array.isEmpty else {
//        
//        self.sections.value = [MySection(header : "Favorite Albums", items : [])]
//        return array
//        
//    }
//    
//    return array
//    
//    }
//    .flatMap { (albumIdsToDisplay: [Int]) -> Observable<[Album]> in
//        
//        return InstaPhotoApiService().getAlboms()
//            .map { (allAlbums: [Album]) -> [Album] in
//                
//                return allAlbums.filter { (album) -> Bool in
//                    return albumIdsToDisplay.contains(album.id!)
//                }
//                
//        }
//        
//}

    init() {
        
        let arrayComMessId = Comment.storage
            .map { (tuple : (Int, Variable<Comment>)) -> Observable <Int>  in
                    return Observable.just(tuple.0)
        }.combineLatest { $0 }
        
        
        let arrayMessage = MessagesContext.messages.asObservable()
        
        
        //let result = zip(arrayComMessId, arrayMessage)
            
        arrayComMessId.flatMap { _ in
            
            return arrayMessage
            
            }.map { (messages : [Message]) -> [ViewModelCell] in
                
                let a : [Message] = messages.filter{ (message : Message) -> Bool in
                    
                    return true
                }
                
                let b : [ViewModelCell] = a.map { (message : Message) -> ViewModelCell in
                    
                    return ViewModelCell(message: message)
                }
                
                return b
            }.map { (cells : [ViewModelCell]) -> [CommentedMessageSection] in
                
                return [CommentedMessageSection (header : "Favourite Albums", items : cells)]
                
            }
            .subscribeNext { (sections: [CommentedMessageSection]) in
                
                self.displayData.value = sections
            }
            .addDisposableTo(bag)
        
        
        
        
        
//            Comment.storage
//                .map { (tuple : (Int, Variable<Comment>)) -> Observable<Comment>  in
//                    return tuple.1.asObservable()
//                }
//                .combineLatest { $0 }
//                .flatMap { _ in
//                    
//                     return Message.storage
//                        .map { (tuple : (Int, Variable<Message>)) -> Observable <Message>  in
//                            return tuple.1.asObservable()
//                        }
//                        .combineLatest { $0 }
//                }
//                .map { (messages : [Message]) -> [ViewModelCell] in
//                    
//                    let a : [Message] = messages.filter{ (message : Message) -> Bool in
//                        
//                        return (Comment.storage[message.id] == message.id)
//                    }
//                    
//                    let b : [ViewModelCell] = a.map { (message : Message) -> ViewModelCell in
//                        
//                        return ViewModelCell(message: message)
//                    }
//                    
//                    return b
//                }
//                
//                .map{ (cells : [ViewModelCell]) -> [CommentedMessageSection] in
//                    
//                    return [CommentedMessageSection (header : "Favourite Albums", items : cells)]
//                    
//                }
//                .subscribeNext { (sections: [CommentedMessageSection]) in
//                    
//                    self.displayData.value = sections
//                }
//                .addDisposableTo(bag)
//            
        
        
//        Comment.storage
//            .map { (tuple : (Int, Variable<Comment>)) -> Observable<Comment>  in
//                return tuple.1.asObservable()
//            }
//            .combineLatest { $0 }
//            
//            .flatMap { (comments : [Comment]) -> Observable<[Message]> in
//                
//                //return  MessagesContext.messages.asObservable()
//                
//                
//            }
//
//          Message.storage
//            .map { (tuple : (Int, Variable<Message>)) -> Observable<Message>  in
//                    return tuple.1.asObservable()
//            }
//           //.combineLatest { $0 }
//           .map { (messages : [Message]) -> [ViewModelCell] in
//                
//                let a : [Message] = messages.filter{ (message : Message) -> Bool in
//                    
//                    return (Comment.storage[message.id] == message.id)
//                }
//                
//                let b : [ViewModelCell] = a.map { (message : Message) -> ViewModelCell in
//                    
//                    return ViewModelCell(message: message)
//                }
//                
//                return b
//            }
//            
//            .map { (cells : [ViewModelCell]) -> [CommentedMessageSection] in
//                
//                return [CommentedMessageSection (header : "Commented messages", items : cells)]
//                
//            }
//            .subscribeNext { (sections: [CommentedMessageSection]) in
//                
//                self.displayData.value = sections
//            }
//            .addDisposableTo(bag)
//        
//    }
//    

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

