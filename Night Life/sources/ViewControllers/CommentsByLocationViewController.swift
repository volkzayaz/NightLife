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
    
    private var viewModel = CommentsByLocationViewModel()
    
    private let dataSource = RxTableViewSectionedAnimatedDataSource<CommentsSection>()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataSource()
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect.zero)
        label.text = dataSource.sectionAtIndex(section).header
        return label
    }
    
    private func loadDataSource() {
    
        viewModel.displayData
            .asObservable().bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(bag)
        
        dataSource.configureCell = { (_, tv, ip, item) in
            
            let cell = tv.dequeueReusableCellWithIdentifier("located comment cell", forIndexPath: ip) as! LocatedCommentTableCell
            cell.setLocatedComment(item.comment)
            return cell
        }
        
        dataSource.canEditRowAtIndexPath = { _ in true }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
            
        self.tableView.rx_itemDeleted
            .map { indexPath in
                return (indexPath, self.dataSource.itemAtIndexPath(indexPath))
            }
            .subscribeNext{[unowned self] value in
                
                self.viewModel.deleteComment(value.0.row, value: value.1)
                //var a = value.1.comment
                self.tableView.reloadData()
            }
            .addDisposableTo(self.bag)
        
        self.tableView.rx_itemSelected
            .subscribeNext{[unowned self] ip in
                self.viewModel.selectedComment(atIndexPath: ip)
            }
            .addDisposableTo(self.bag)
    
    }
    
}
}

struct CommentsSection {
    
    var header: String
    var items: [Item]
    
}


extension CommentsSection : AnimatableSectionModelType  {
    
    typealias Item = ViewModelCommentCell
    typealias Identity = String
    
    
    var identity : String {
        return header
    }
    
    init(original: CommentsSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    
}
