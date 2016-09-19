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
import RxDataSources

class MessageViewController: UIViewController, UITableViewDelegate {

    var viewModel: MessageViewModel!
    var commentViewModel : CommentViewModel?
    @IBOutlet weak var tableView: UITableView!

    private let bag = DisposeBag()
    private let dataSource = RxTableViewSectionedAnimatedDataSource<CommentSection>()
    
    @IBOutlet weak var commentEnteredText: UITextView!
    @IBOutlet weak var saveComment: UIButton!
    @IBOutlet weak var textView: UITextView!
 
       override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        self.tableView
            .rx_setDelegate(self)
            .addDisposableTo(bag)

        self.title = viewModel.message.title
      
        commentViewModel = CommentViewModel(message: viewModel.message)
      
        textView.text = viewModel.message.body
        
        saveComment.rx_tap.asObservable()
            
            .subscribe(onNext : { [weak self] in
                
                self!.commentViewModel!.createComment(self!.commentEnteredText.text )                
                self!.commentEnteredText.text = "enter comment"
                
            }).addDisposableTo(bag)
      
        
        self.loadDataSource()
       
        
        
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
    
    
    func loadDataSource () {
        
        self.commentViewModel!.commentCountObservable
            .subscribeNext { [weak self] (count : Int) in
               
                self!.tableView.reloadData()
            }
            .addDisposableTo(self.bag)
        

        commentViewModel!.displayData!
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(bag)
        
        self.dataSource.configureCell = { (_, tv, ip, item) in
            
            let cell = tv.dequeueReusableCellWithIdentifier("comment cell", forIndexPath: ip) as! CommentTableCell
            cell.setComment(item)
            return cell
        }

        
        dataSource.canEditRowAtIndexPath = { _ in true }
        
        tableView.rx_itemDeleted
            .subscribeNext{[unowned self] value in
                self.commentViewModel!.deleteComment(value.row)
            }
            .addDisposableTo(bag)
        
       
    }

    
    func mock() {}
}



struct CommentSection {
    
    var commentItems: [Comment]
    
    
}


extension CommentSection : AnimatableSectionModelType  {
    
    typealias Item = Comment
    typealias Identity = String
    
    var items: [Item] {
        return commentItems
    }
   
    var identity : String {
        return ""
    }
    
    init(original: CommentSection, items: [Item]) {
        self = original
        self.commentItems = items
    }
    
    
    init(items: [Comment]) {
        self.commentItems = items
    }
    
}





