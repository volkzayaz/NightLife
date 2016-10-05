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