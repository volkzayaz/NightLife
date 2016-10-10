//
//  CommentStorage.swift
//  GlobBar
//
//  Created by Evgeny on 9/21/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CommentStorage {
    
    
    static var commentStorage: [Int : Variable<[Comment]>] = [ : ]
    
    static func saveMessageComments (message : Message, textComment : String) {

        if commentStorage[message.id] == nil {
            commentStorage[message.id] = Variable([])
        }
        commentStorage[message.id]?.value.append(Comment(textComment : textComment))
        

        print("IN STORAGE")
        print(message.id)
        print(commentStorage[message.id]?.value.count)
        let a = commentStorage[message.id]?.value.count
        for var i = 0; i < a; i++ {
        print((commentStorage[message.id]?.value[i])!.textComment)
        }
    }
    

    
    static func getCommentedMessages () -> Observable<[Message]> {

//        var commentedMessages : [Message] = []
        print ("CommentStorage")
        print(Array(commentStorage.keys))
        
        let commentedMessages = MessagesContext.messages
            .asObservable()
            .flatMapLatest { messages -> Observable<[Message]> in
                messages
                    .flatMap {
                        $0.observableEntity()?.asObservable()
                    }
                    .combineLatest { commentedMessages in
                        let commentedMessages : [Message] = commentedMessages.filter {
                            CommentStorage.commentStorage[$0.id]?.value.count > 0
                        }
                        return commentedMessages
                }
        }
        return commentedMessages

        
        
//        for anMessageId in (Array(commentStorage.keys)) {
//
//            print(anMessageId)
//            print (commentStorage[anMessageId]?.value[1].textComment)
//            
//            Message.storage.indexForKey(anMessageId)
//        }
//    
//        return Observable.just(commentedMessages)
        
        
        

//       return Array(commentStorage.keys)
        
//        return self.getAllAlbums()
//            .map{ (allAlbums : [Album]) -> [Album] in
//                return allAlbums.filter { (album) -> Bool in
//                    return likedAlbumList.contains(album.albumId!)
//                }

    }
    

    
    
    
//    static func getCommentedMessages () -> Observable <[Int]> {
//        var commentedMessages : [Int] = []
//        print("COMMENTSTORAGE = \(commentStorage.count)")
//        for anMessageId in commentStorage as! [Dictionary <Int, Variable<[Comment]>>] {
//         print ("CommentStorage = \(anMessageId)")
////            print (self.commentStorage[anMessageId])
////            if self.commentStorage[anMessageId]?
//        }
//    }
    
   
    
}