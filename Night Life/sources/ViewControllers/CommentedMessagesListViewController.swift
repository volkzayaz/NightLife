//
//  CommentedMessagesListViewController.swift
//  GlobBar
//
//  Created by Administrator on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

import AHKActionSheet
import SWRevealViewController
import Alamofire
import ObjectMapper



class CommentedMessagesListViewController : UIViewController {
    
    private let commentedMessagesListVM = CommentedMessageListViewModel()
    private let bag = DisposeBag()
    
    var dataSource: RxTableViewSectionedAnimatedDataSource<CommentedMessageSection>?

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CONTROLLER")
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        

        tableView.rx_itemSelected
            .subscribeNext{[unowned self] indexPath in
                self.commentedMessagesListVM.selectedCommentedMessage(atIndexPath: indexPath)
            }
            .addDisposableTo(bag)
        
        commentedMessagesListVM.detailsCommentedMessage.asDriver()
        .filter { ($0 != nil) }.map { $0! }
        .driveNext { [unowned self] in
            self.performSegueWithIdentifier("CommentedMessageDetails", sender: nil)
        }
        .addDisposableTo(bag)
        
        
        
//        viewModel.detailMessageViewModel.asDriver()
//            .filter { $0 != nil }.map { $0! }
//            .driveNext {[unowned self] in
//                self.performSegueWithIdentifier("MessageDetailsScreen", sender: nil)
//            }
//            .addDisposableTo(bag)

        
//
////        tableView.rx_setDelegate(self)
        
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<CommentedMessageSection>()
        
        commentedMessagesListVM.sections.asObservable()
        .bindTo(tableView.rx_itemsWithDataSource(dataSource))
        .addDisposableTo(bag)

      
        dataSource.configureCell = { (dataSource, tableView, indexPath, cellViewModel) in
            let cell = tableView.dequeueReusableCellWithIdentifier("message cell", forIndexPath: indexPath)
            as! MessageTableCell
            
//            cell.setCommentedMessage(cellViewModel.message)
            print("cellViewModel.message = \(cellViewModel.message)")
            cell.setMessage(cellViewModel.message)
            
            return cell
        }
  
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CommentedMessageDetails" {
            let controller = segue.destinationViewController as! CommentedMessageViewController
            
            controller.messageVM = commentedMessagesListVM.detailsCommentedMessage.value
            
//            controller.commentedMessageVM = commentedMessagesListVM.detailsCommentedMessage.value
//            controller.commentedMessageVM = commentedMessagesListVM.detailsCommentedMessage.value
//            controller.viewModel = viewModel.detailMessageViewModel.value
        }
    }

    
    
}
