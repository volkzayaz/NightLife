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
    
    @IBOutlet weak var textView: UITextView!
    
    
    @IBOutlet weak var commentTextField: UITextField!
    
    
    override func viewDidLoad() {
        print( "~~~~~~~~~~~~~~~" )
        
        print (messageVM.message.id)
        
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