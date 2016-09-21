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
    
    @IBAction func saveCommentButton(sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = viewModel.message.title
        
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
