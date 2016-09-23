//
//  MessageViewController.swift
//  Night Life
//
//  Created by admin on 12.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift


class MessageViewController: UIViewController {

    var viewModel: MessageViewModel!
    
    private let bag = DisposeBag()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var savedComment: UILabel!
    
    @IBAction func saveCommentButton(sender: UIButton) {
        
        print ("MessageViewController")
        viewModel.commentObservable = commentTextField.rx_text.asObservable()
        viewModel.savedComment.asObservable().bindTo(savedComment.rx_text).addDisposableTo(bag)
        viewModel.saveComment(commentTextField.text!)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = viewModel.message.title
        print(viewModel.message.id)
        
        textView.text = viewModel.message.body
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
