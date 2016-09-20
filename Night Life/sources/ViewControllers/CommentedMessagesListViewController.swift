//
//  MessagesListViewController.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import AHKActionSheet
import SWRevealViewController
import Alamofire
import ObjectMapper

import RxDataSources

class CommentedMessagesListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = CommentedMessagesListViewModel()
    
    private let dataSource = RxTableViewSectionedAnimatedDataSource<CommentedMessageSection>()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        viewModel.displayData
            .asObservable().bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(bag)
        
        dataSource.configureCell = { (_, tv, ip, item) in
            
            let cell = tv.dequeueReusableCellWithIdentifier("message cell", forIndexPath: ip) as! MessageTableCell
            cell.setMessage(item.message)
            return cell
        }
        
        dataSource.canEditRowAtIndexPath = { element in
            return element.indexPath.row != 0
        }
        
        tableView.rx_itemDeleted
            .subscribeNext{[unowned self] value in
                self.viewModel.deleteMessage(value.row)
            }
            .addDisposableTo(bag)
        
        viewModel.detailMessageViewModel.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext {[unowned self] in
                self.performSegueWithIdentifier("MessageDetailsScreen", sender: nil)
            }
            .addDisposableTo(bag)
        
        tableView.rx_itemSelected
            .subscribeNext{[unowned self] ip in
                self.viewModel.selectedMessage(atIndexPath: ip)
            }
            .addDisposableTo(bag)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MessageDetailsScreen" {
            let controller = segue.destinationViewController as! MessageViewController
            
            controller.viewModel = viewModel.detailMessageViewModel.value
        }
    }
}




struct CommentedMessageSection {
    
    var header: String
    var items: [Item]
        
}


extension CommentedMessageSection : AnimatableSectionModelType  {
    
    typealias Item = ViewModelCell
    typealias Identity = String
    
    
    var identity : String {
        return ""
    }
    
    init(original: CommentedMessageSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    
}
