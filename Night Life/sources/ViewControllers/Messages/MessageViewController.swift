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

class MessageViewController: UIViewController {

    var viewModel: MessageViewModel!

    @IBOutlet weak var tableView: UITableView!
    
    var commentViewModel : CommentViewModel?

    private let bag = DisposeBag()
    private let dataSource = RxTableViewSectionedAnimatedDataSource<CommentSection>()
    
    @IBOutlet weak var commentEnteredText: UITextView!
    @IBOutlet weak var saveComment: UIButton!
    @IBOutlet weak var textView: UITextView!
 
       override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
               
        self.title = viewModel.message.title
        commentViewModel = CommentViewModel(message: viewModel.message)
        textView.text = viewModel.message.body
                
        saveComment.rx_tap.asObservable()
            
            .subscribe(onNext : { [unowned self] in
                
                self.commentViewModel!.createComment(self.commentEnteredText.text )
                
                self.commentEnteredText.text = "enter comment"
                
                self.tableView.reloadData()
                self.loadDataSource ()
                
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
    
    
        guard commentViewModel!.displayData != nil else { return }
        
        commentViewModel!.displayData!
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(bag)
        
        dataSource.configureCell = { (_, tv, ip, item) in
            
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
    
    //var header: String
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





