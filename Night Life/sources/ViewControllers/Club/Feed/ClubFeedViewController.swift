//
//  ReviewsListViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

import AHKActionSheet

class ClubFeedViewController : UIViewController {
    
    let disposeBag = DisposeBag()
    
    var viewModel : ClubFeedViewModel!
    
    private weak var checkInController : CheckinViewController? = nil
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    @IBOutlet weak var clubLogoImageView: UIImageView!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var adresLabel: UILabel!
    @IBOutlet weak var lastCheckinsView: CircularIconsGroupView!
    
    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var recomendationLabel: UILabel!
    
    @IBOutlet weak var filtersSegmentedControl: UISegmentedControl!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var addReportBtn: UIButton!
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var addVideoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (viewModel == nil) { fatalError("ViewModel must be instantiated prior to using ClubFeedViewController") }
        
        //setting up UI
        self.title = "Reviews"
        
        filtersSegmentedControl.setTitleTextAttributes([
                NSFontAttributeName : UIConfiguration.appFontOfSize(10)
            ], forState: .Normal)
        
         
        
        ////binding
        
        addReportBtn.rx_tap.asObservable()
            .subscribeNext
            { [unowned self] _ in
                self.viewModel.addReport()
            }
            .addDisposableTo(disposeBag)
        
        addPhotoBtn.rx_tap.asObservable()
            .subscribeNext
            { [unowned self] _ in
                self.viewModel.addMedia(.Photo)
            }
            .addDisposableTo(disposeBag)

        addVideoBtn.rx_tap.asObservable()
            .subscribeNext
            { [unowned self] _ in
                self.viewModel.addMedia(.Video)
            }
            .addDisposableTo(disposeBag)
        
        
        viewModel.infoMessage.asDriver()
            .filter{ $0 != nil }
            .map{ $0! }
            .driveNext { [unowned self] message in
                self.showInfoMessage(withTitle: message.title, message.message)
            }
            .addDisposableTo(disposeBag)

        self.filtersSegmentedControl.setTitle("Last \(TodayDayManager.dayOfWeekText())'s Feed", forSegmentAtIndex: 1)
        
        guard let clubDriver = viewModel.club.observableEntity()?.asDriver() else {
            fatalError("Can't present ClubFeed screen without stored club with id \(viewModel.club.id)")
        }
        
        clubDriver
            .map{ $0.name }
            .drive(clubNameLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        clubDriver
            .map{ $0.adress }
            .drive(adresLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        clubDriver
            .map{ $0.logoImageURL }
            .distinctUntilChanged()
            .flatMap{ ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(clubLogoImageView.rx_imageAnimated(kCATransitionFade))
            .addDisposableTo(disposeBag)
        
        clubDriver
            .map{ $0.coverPhotoURL }
            .distinctUntilChanged()
            .flatMap{ ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(coverPhotoImageView.rx_imageAnimated(kCATransitionFade))
            .addDisposableTo(disposeBag)

        clubDriver
            .flatMap { club in
                club.lastCheckedInUsers /// all lastCheckedInUsers
                    .flatMap { ///filtering out users taht are not in storage
                        $0.observableEntity()?.asDriver() /// getting observable user from storage
                    }
                    .combineLatest { actualUsers in ///mapping true users to their picture URLs
                        actualUsers.map { $0.pictureURL! }
                }
            }
            .driveNext{ [unowned self] icons in
                self.lastCheckinsView.addIconURLs(icons)
            }
            .addDisposableTo(disposeBag)
        
        clubDriver
            .map{ $0.clubDescriptors.ageGroup ?? "" }
            .drive(recomendationLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        clubDriver
            .map{ $0.clubDescriptors.musicType ?? "" }
            .drive(musicLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        clubDriver
            .map{ $0.clubDescriptors.openingHours ?? "" }
            .drive(scheduleLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        viewModel.addPhotoAction.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] message in
                
                self.showSimpleQuestionMessage(withTitle: message.0.title, message.0.message, message.yesHandler, message.noHandler)
                
            }
            .addDisposableTo(disposeBag)
        
        filtersSegmentedControl.rx_value
            .subscribeNext{ [unowned self] value in
                self.viewModel.filterAtIndexSelected(value)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.activeViewModel.asDriver()
            .driveNext { [unowned self] maybeViewModel in
                
                guard let viewModel = maybeViewModel else {
                    self.switchActiveViewControllerTo(nil)
                    return
                }
                
                var viewControllerToPresent: UIViewController? = nil
                if viewModel is CheckinViewModel {
                    
                    let checkinController = self.storyboard!
                        .instantiateViewControllerWithIdentifier("CheckinViewController") as! CheckinViewController
                    checkinController.viewModel = (viewModel as! CheckinViewModel)
                    
                    viewControllerToPresent = checkinController
                    
                }
                else if viewModel is CreateReportViewModel {
                    
                    let checkinController = self.storyboard!
                        .instantiateViewControllerWithIdentifier("CreateReportViewController") as! CreateReportViewController
                    checkinController.viewModel = (viewModel as! CreateReportViewModel)
                    
                    viewControllerToPresent = checkinController
                    
                }
                else if viewModel is AddMediaViewModel {
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("AddMediaViewController") as!
                        AddMediaViewController
                    
                    controller.viewModel = viewModel as! AddMediaViewModel
                    
                    viewControllerToPresent = controller
                }
                else {
                    fatalError("Logic error. Passed active viewController was not properly recognized")
                }
                
                self.switchActiveViewControllerTo(viewControllerToPresent)
                
            }
            .addDisposableTo(disposeBag)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        clubLogoImageView.layer.cornerRadius = clubLogoImageView.frame.size.width / 2
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "feed embedded" {
            
            let controller = segue.destinationViewController as! FeedCollectionViewController
            controller.viewModel = viewModel.feedViewModel
            controller.headerDataSource = self
            
        }
    }
    
}

extension ClubFeedViewController {
    
    /**
     * @discussion This method incapsulated context switching rules
     */
    private func isActiveViewControllerPresented() -> Bool {
        
        guard let navController = self.navigationController,
              let index = navController.viewControllers.indexOf(self) else {
            fatalError("ClubFeedViewController is able to manage navigation only inside UINavigationController")
        }
        
        return index + 1 < navController.viewControllers.count
    }
    
    private func switchActiveViewControllerTo(viewController: UIViewController?) {
        
        guard let controllerToPresent = viewController else {
            if self.isActiveViewControllerPresented() {
                self.navigationController!.popViewControllerAnimated(true)
            }
            
            return
        }
        
        ///in case we have viewController to present
        
        if (!self.isActiveViewControllerPresented())
        {
            self.navigationController!.pushViewController(controllerToPresent, animated: true)
        }
        else
        {
            var controllers = self.navigationController!.viewControllers
            controllers[controllers.count - 1] = controllerToPresent
            
            self.navigationController!.setViewControllers(controllers, animated: true)
        }

        
    }
    
}

extension ClubFeedViewController : FeedHeaderDataSource {
    
    var headerHeight: CGFloat { return 279 }
    
    func populateHeaderView(view: UICollectionReusableView) {
        view.embbedViewAsContainer(headerView)
    }
    
}