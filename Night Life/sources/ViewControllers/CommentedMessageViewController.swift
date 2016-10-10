//
//  CommentedMessageViewController.swift
//  GlobBar
//
//  Created by Evgeny on 9/27/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


class CommentedMessageViewController : UIViewController {
    
    var messageVM: MessageViewModel!
    var commentedMessageVM: CommentedMessageViewModel!
    var bag = DisposeBag()
    
    @IBOutlet weak var textView: UITextView!
    
    
    @IBOutlet weak var commentTextField: UITextField!
    
    
    override func viewDidLoad() {
        print( "~~~~~~~~~~~~~~~" )
        
        print (messageVM.message.id)

        textView.text = messageVM.message.body
        print(CommentStorage.commentStorage[messageVM.message.id]?.value[0].textComment)

//        CommentStorage.commentStorage[messageVM.message.id]?.asObservable()
//            .subscribeNext{ (comments : [Comment]) in
//                return comments.filter { (comment : Comment) -> Bool in
//                print(comment.textComment)
//                    self.textView.text = comment.textComment
//                    return true
//            }
//        }
     
//        commentedMessageVM.messageComment.asObservable()
//            .subscribeNext { (comment : Comment?) in
//                print(comment!.textComment)
//            }
        
        commentedMessageVM.msgCmnt!.asObservable()
            .subscribeNext { (comment : Comment?) in
                print(comment!.textComment)
        }

        
        
        
        
        
//        commentedMessageVM.messageCommentsList.asObservable()
//            .subscribeNext { (comments : [Comment]) in
//                self.textView.text = comments[0].textComment
//            }
//                .addDisposableTo(bag)
        
        
//        CommentedMessageViewModel()
//        commentedMessageVM.messageComment.asObservable()
//            .subscribeNext { (comment : Comment?) in
//            self.textView.text = comment?.textComment
//        }
//        .addDisposableTo(bag)


        
        
        
        
//        commentedMessageVM.messageCommentsList.asObservable()
//            .subscribeNext { (comments : [Comment]) in
//            
//        }
//        .addDisposableTo(bag)
        
        
        
//        CommentedMessageViewModel()
        
        
 
        
        
        
        
        
        
          
//        CommentStorage.commentStorage[messageVM.message.id]?.asObservable()
//            .map { (comments : [Comment]) -> Comment in
//               return comments.
//        }
        
                
                
                
//                return (comments.filter{ (comment : Comment) -> Bool in
//                    print("**** = \(comment)")
//                    return true
//                }).cs_arrayValue()
//                
////                return (comments.filter{ (comment : Comment) -> String in
////                return comment.textComment
////            })
//        }
            
            
//            .subscribeNext{ (comments : [Comment]) in
//
////                comments.map({ (comment : Comment) -> String in
////                print(comment)
////            })
//        }
        
        
//        textView.text = CommentStorage.commentStorage[messageVM.message.id]
        
        
//        textView.text = messageVM.message.body
        
//        commentedMessageVM.messageComments.asObservable()
        
        
//        textView.text = commentedMessageVM.messageComments.asObservable().subscribeNext{ (comments : [Comment]) in
//           
//                print(comments)
//            }
//        }
//        .addDisposableTo(bag)
        
//        textView.text = String(messageVM.message.id)
//        textView.text = CommentStorage.commentStorage.
//            .flatMap({ ((Int, Variable<[Comment]>)) -> SequenceType in
//            
//        }).indexForKey(messageVM.message.id)
        
//            .map{ (DictionaryIndex<Int, Variable<[Comment]>>) -> <[Comment]> in
//            code
//        }
    }
    
}