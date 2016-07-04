//
//  ViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import SWRevealViewController

import Alamofire
import ObjectMapper

class ClubsListViewController: UITableViewController {

    var viewModel: ClubListViewModel!
    
    private let bag = DisposeBag()
  
    override func loadView() {
        super.loadView()
        
        if viewModel == nil { assert(false, "view model must be initialized before using view controller")  }
        
        self.tableView.rowHeight = 170
        self.tableView.estimatedRowHeight = 170
        
        viewModel.clubs.asDriver()
            .driveNext { [unowned self] _ in self.tableView.reloadData() }
            .addDisposableTo(bag)
        
        viewModel.wireframe.asObservable()
            .filter{ $0 != nil }
            .map { $0! }
            .subscribeNext { [unowned self] wireframe in
                self.performSegueWithIdentifier(wireframe.segueIdentifier, sender: nil)
            }
            .addDisposableTo(bag)
        
        viewModel.errorMessage.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] message in
                self.showInfoMessage(withTitle: "Error", message)
            }
            .addDisposableTo(bag)
        
        viewModel.clubs.asDriver()
            .driveNext { [unowned self] _ in
                self.tableView.reloadSections([0], animationStyle: .Automatic)
                self.tableView.scrollRectToVisible(CGRect(x: 0,y: 0,width: 1,height: 1), animated: true)
            }
            .addDisposableTo(bag)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show club feed"
        {
            guard let vm = viewModel.wireframe.value?.viewModel else {
                assert(false, "Can't go to checkin screen without selected club")
                return
            }
            
            let controller = segue.destinationViewController as! ClubFeedViewController
            controller.viewModel = vm
        }
    }
}

extension ClubsListViewController /*TableViewDataSource, delegate*/ {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.clubs.value.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("club cell", forIndexPath: indexPath) as! ClubTableCell
        
        let club = viewModel.clubs.value[indexPath.row]
        cell.setClub(club)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewModel.clubSelected(atIndexPath: indexPath)
    }
    
}
