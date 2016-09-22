//
//  CommentsByLocationViewController.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import AHKActionSheet
import SWRevealViewController
import Alamofire
import ObjectMapper

import RxDataSources

class CommentsByLocationViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = CommentsByLocationViewModel()
    
    private let dataSource = RxTableViewSectionedAnimatedDataSource<CommentsSection>()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.displayData
            .asObservable().bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(bag)
        
        dataSource.configureCell = { (_, tv, ip, item) in
            
            let cell = tv.dequeueReusableCellWithIdentifier("located comment cell", forIndexPath: ip) as! LocatedCommentTableCell
            cell.setLocatedComment(item.comment)
            return cell
        }
        
        dataSource.canEditRowAtIndexPath = { _ in true }
        
        tableView.rx_itemDeleted
            .subscribeNext{[unowned self] value in
                self.viewModel.deleteComment(value.row)
            }
            .addDisposableTo(bag)
        
        tableView.rx_itemSelected
            .subscribeNext{[unowned self] ip in
                self.viewModel.selectedComment(atIndexPath: ip)
            }
            .addDisposableTo(bag)
        
        
    }
    
}


struct CommentsSection {
    
    var header: String
    var items: [Item]
    
}


extension CommentsSection : AnimatableSectionModelType  {
    
    typealias Item = ViewModelCommentCell
    typealias Identity = Int
    
    
    var identity : Int {
        return 0
    }
    
    init(original: CommentsSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    
}
