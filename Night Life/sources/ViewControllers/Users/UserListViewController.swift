//
//  UserListViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/21/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController

import RxSwift
import RxCocoa
import RxDataSources

class UserListViewController : UIViewController {
    
    var viewModel : UsersListViewModel!
    
    private let dataSource = RxTableViewSectionedAnimatedDataSource<UserSection>()
    private let bag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = 70
        }
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noResultsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil { fatalError("Can't use class without initialized view model") }
        
        if !viewModel.shouldDisplaySearchBar {
            tableView.tableHeaderView = nil
        }
        
        dataSource.configureCell = { (_, tv, ip, item) in
            
            let cell = tv.dequeueReusableCellWithIdentifier("UserListCell", forIndexPath: ip) as! UserListCell
            
            cell.setViewModel(item)

            return cell
        }
        
        tableView.rx_modelSelected(UserViewModel.self)
            .asDriver()
            .driveNext { [unowned self] m in
                self.viewModel.userViewModelSelected(m)
            }
            .addDisposableTo(bag)
        
        viewModel.displayData
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(bag)
        
        let a = !viewModel.shouldDisplaySearchBar
        viewModel.displayData
            .map{ sections in
                guard let section = sections.first else { return true }
                
                return section.items.count > 0 || a
            }
            .skip(1)///initial empty dataset
            .startWith(true)
            .drive(noResultsView.rx_hidden)
            .addDisposableTo(bag)

        viewModel.searchBarObservable.value = searchBar.rx_text.asObservable()
        viewModel.title.asObservable()
            .subscribeNext { [unowned self] title in
                self.title = title
            }
            .addDisposableTo(bag)
        
        viewModel.selectedUser.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] _ in
                self.performSegueWithIdentifier("show profile segue", sender: nil)
            }
            .addDisposableTo(bag)
        
        viewModel.message.asDriver()
            .filter { $0 != nil }.map { $0! }
            .filter { $0.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 }
            .driveNext { [unowned self] message in
                self.showInfoMessage(withTitle: "Success", message)
            }
            .addDisposableTo(bag)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show profile segue" {
            
            let controller = segue.destinationViewController as! UserProfileViewController
            controller.viewModel = UserProfileViewModel( userDescriptor: viewModel.selectedUser.value!.user )
            
        }
    }
}

struct UserSection : AnimatableSectionModelType  {
    
    typealias Item = UserViewModel
    typealias Identity = String
    
    var items: [Item] {
        return userItems
    }
    
    var identity : String {
        return ""
    }
    
    init(original: UserSection, items: [Item]) {
        self = original
        self.userItems = items
    }
    
    
    var userItems: [UserViewModel]
    
    init(items: [UserViewModel]) {
        self.userItems = items
    }
    
}
