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
   
    @IBOutlet weak var tableView: UITableView!
    private let dataSource = RxTableViewSectionedAnimatedDataSource<CommentSection>()
    private let bag = DisposeBag()
    
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
      
        textView.text = viewModel.message.body
        
        viewModel.commentViewModel!.commentCountObservable
            .subscribeNext { [weak self] (count : Int) in
                self!.loadDataSource()
            }.addDisposableTo(bag)

        saveComment.rx_tap.asObservable()
            
            .subscribe(onNext : { [weak self] in
                
                self!.viewModel.commentViewModel!.createComment(self!.commentEnteredText.text )
                self!.commentEnteredText.text = "enter comment"
                
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
    
    
    func loadDataSource () {

        viewModel.commentViewModel!.displayData!
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(bag)
        
        self.dataSource.configureCell = { (_, tv, ip, item) in
            
            let cell = tv.dequeueReusableCellWithIdentifier("comment cell", forIndexPath: ip) as! CommentTableCell
            cell.setComment(item)
            
            return cell
        }

        
        dataSource.canEditRowAtIndexPath = { element in            
   
            if element.indexPath.row == 0 {
                return false
            } else {
                return true }}
        
        tableView.rx_itemDeleted
            .subscribeNext{[unowned self] value in
                self.viewModel.commentViewModel!.deleteComment(value.row)
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





