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
//    var messageComments : Variable <[Comment]> = Variable([])
    var messageComment : Variable <Comment?> = Variable(nil)
    
    init() {
        
                
        CommentStorage.commentStorage[messageVM.message.id]?.asObservable()
            .map { (comments : [Comment]) -> Comment in

//                return comments.forEach({ (comment : Comment) in
//                    self.messageComment.value = comment
//                })
//        }
        
                
                return comments.filter({ (comment : Comment) -> Bool in
                self.messageComment.value = comment
                    return true
            })
                .first!
        }

        
      
//        self.messageComments.value = ...
        
        
    }
    
}