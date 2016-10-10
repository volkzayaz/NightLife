//
//  CommentedMessageViewModel.swift
//  GlobBar
//
//  Created by Administrator on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

class  CommentedMessageViewModel {
    
    var messageVM: MessageViewModel!
//    var messageCommentsList : Variable<[Comment]> = Variable([])
    var messageComment : Variable <Comment?> = Variable(nil)
    
    var msgCmnt : Variable <Comment>? {
        
        didSet {
            
            CommentStorage.commentStorage[messageVM.message.id]?.asObservable()
                .subscribeNext{ (comments : [Comment]) in
                    return comments.filter { (comment : Comment) -> Bool in
                        print(comment.textComment)
                        self.messageComment.value = comment
                        return true
                    }
            }

            
            
        }
    }
    
    
//    var messageComment : Variable <Comment> {
//        
//        print(CommentStorage.commentStorage[messageVM.message.id]!)
////        return CommentStorage.commentStorage[messageVM.message.id]
//         }
//    }

    
//    var switchLikeStatus : Observable<Bool> {
//        
//        return AlbumStorage.storageLikedAlbumId.asObservable()
//            .map{ (liked : Set<Int>) -> Bool in
//                return liked.contains(self.album.albumId!)
//        }
 
    
 
    
    init() {
     
        print("~~~~~~~~CommentMessageVM~~~~~~~~~~")
        
      
        CommentStorage.commentStorage[messageVM.message.id]?.asObservable()
            .subscribeNext{ (comments : [Comment]) in
                return comments.filter { (comment : Comment) -> Bool in
                    print(comment.textComment)
                    self.messageComment.value = comment
                    return true
                }
        }

        
        
        
        
        
        
        
        
        
        
        
//        self.messageCommentsList.value.append(Comment.init(textComment: textComm))
        
        
//        CommentStorage.commentStorage[messageVM.message.id]?.asObservable()
////            .map { (comments : [Comment]) -> Comment in
//            .subscribeNext{ (comments : [Comment]) in
//            self.messageCommentsList.value = comments
//        }
        
                
//        }
/*
//                return comments.forEach({ (comment : Comment) in
//                    self.messageComment.value = comment
//                })
//        }
        
                
                return comments.filter({ (comment : Comment) -> Bool in
                print("~~~~~~~~~ \(comment)")
                    self.messageComment.value = comment
                    return true
            })
                .first!
        }

        
      
//        self.messageComments.value = ...
*/
        
    }
    
}