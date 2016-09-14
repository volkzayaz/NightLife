//
//  MessageViewController.swift
//  Night Life
//
//  Created by admin on 12.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MessageViewController: UIViewController {

    var viewModel: MessageViewModel!
    
    var viewModelComment : CommentViewModel!
    
    private let bag = DisposeBag()
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var saveComment: UIButton!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = viewModel.message.title
        
        textView.text = viewModel.message.body
        
        guard viewModel.comment.body != "" else { return commentTextField.text = "No comments"}
        
        commentTextField.text = viewModel.comment.body
        
        saveComment.rx_tap.asObservable()
            
           .subscribe(onNext : {
        
           self.commentTextField.resignFirstResponder()
            
           guard self.commentTextField.text != "No comments" else {return}
            
           self.viewModelComment.comment.body = self.commentTextField.text!
                
           self.viewModelComment.saveComment(self.viewModelComment.comment, message: self.viewModel.message)
 
        
        }).addDisposableTo(bag)
        
        
        //= viewModelComment.comment.body
//        let b = UIBarButtonItem(image: UIImage(named: "messageScreenDeleteBtn"), style: .Plain, target: self, action: #selector(mock))
//        
//        b.rx_tap
//            .subscribeNext { [unowned self] in
//  
//
//            }
//            .addDisposableTo(bag)
//        
//        self.navigationItem.rightBarButtonItem = b

    }
    
    func mock() {}
}
