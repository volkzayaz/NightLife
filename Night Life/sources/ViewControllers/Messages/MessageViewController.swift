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
    var viewModelComment : CommentViewModel?
    private let bag = DisposeBag()
    
    @IBOutlet weak var commentEnteredText: UITextView!
    @IBOutlet weak var saveComment: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var createdLabel: UILabel!
       override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = viewModel.message.title
        viewModelComment = CommentViewModel(message: viewModel.message)
        textView.text = viewModel.message.body
        
        if viewModelComment!.comment == nil {
            commentLabel.text = "No comments"
            
        } else {
        
        commentLabel.text = viewModelComment!.comment!.body
        
        }
            
        saveComment.rx_tap.asObservable()
            
           .subscribe(onNext : { [unowned self] in
        
           self.viewModelComment!.createComment(self.viewModel.message, body: self.commentEnteredText.text )
           self.commentLabel.text = self.viewModelComment!.comment!.body
           self.commentEnteredText.text = "enter comment"
        
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
