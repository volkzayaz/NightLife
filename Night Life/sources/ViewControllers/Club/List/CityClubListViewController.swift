//
//  MainClubListViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import AHKActionSheet

class CityClubListViewController: UIViewController {
    
    let viewModel = CityClubListViewModel()
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.title
            .driveNext { [unowned self] title in
                self.title = title
            }
            .addDisposableTo(bag)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "club list embedded" {
            
            let controller = segue.destinationViewController as! ClubsListViewController
            controller.viewModel = viewModel.clubsViewModel
            
        }
    }
    
}