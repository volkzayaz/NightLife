//
//  CityFeedViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController

import RxSwift
import RxCocoa
//import TodayDayManager

class CityFeedViewController : UIViewController {
    
    var viewModel = CityFeedViewModel()
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterSegmentedControl.rx_value
            .subscribeNext{ [unowned self] value in
                self.viewModel.filterAtIndexSelected(value)
            }
            .addDisposableTo(disposeBag)
        
        filterSegmentedControl.setTitleTextAttributes([
            NSFontAttributeName : UIConfiguration.appFontOfSize(10)
            ], forState: .Normal)
        
        viewModel.titleObservable
            .subscribeNext{ [weak self] title in
            self?.title = title
        }
        .addDisposableTo(disposeBag)
       
        self.filterSegmentedControl.setTitle("Last \(TodayDayManager.dayOfWeekText())'s Feed", forSegmentAtIndex: 1)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "feed embedded" {
            
            let controller = segue.destinationViewController as! FeedCollectionViewController
            controller.viewModel = viewModel.feedViewModel
            controller.headerDataSource = self
            
        }
    }
}

extension CityFeedViewController : FeedHeaderDataSource {
    
    var headerHeight: CGFloat { return 44 }
    
    func populateHeaderView(view: UICollectionReusableView) {
        view.embbedViewAsContainer(headerView)
    }
}