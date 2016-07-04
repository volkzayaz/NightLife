//
//  LikedClubsListViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController

class LikedClubsListViewController : UIViewController {
    
    let viewModel = LikedClubsListViewModel()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "club list embedded" {
            
            let controller = segue.destinationViewController as! ClubsListViewController
            controller.viewModel = viewModel.clubsViewModel
            
        }
    }
}
