//
//  SideViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController
import RxSwift

import AHKActionSheet

class SideViewController : UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.borderWidth = 1
            avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectCityButton: UIButton!
    @IBOutlet weak var gradientOverlay: UIView! {
        didSet {
            
            let layer = UIConfiguration.naviagtionBarGradientLayer(forSize: CGSize(width: 1000, height: gradientOverlay.frame.size.height))
            
            gradientOverlay.layer.addSublayer(layer)
            
            gradientLayer = layer
        }
    }
    private var gradientLayer : CALayer?
    
    @IBOutlet weak var unreadMessagesLabel: UILabel!
    @IBOutlet weak var facebookInvitationSpinner: UIActivityIndicatorView!
    
    let viewModel = SideViewModel()
    let invitationViewModel = InvitationViewModel()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let observableUser = User.currentUser()?.observableEntity()?.asDriver() else {
            assert (false, "Logic error. Side View controller is instantiated before logged in User exists")
            return
        }
        
        observableUser.map { $0.username }
            .drive(nameLabel.rx_text)
            .addDisposableTo(bag)
        
        observableUser.map { $0.pictureURL! }
            .flatMap { ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(avatarImageView.rx_imageAnimated(kCATransitionFade))
            .addDisposableTo(bag)
        
        viewModel.cities.asDriver()
            .map{ $0 != nil }
            .drive(selectCityButton.rx_enabled)
            .addDisposableTo(bag)
        
        viewModel.currentCityName
            .driveNext{ [unowned self] cityName in
                self.selectCityButton.setTitle(cityName, forState: .Normal)
                
            }
            .addDisposableTo(bag)
        
        let messageCountDriver = MessagesContext.messages
            .asObservable()
            .flatMapLatest { messages -> Observable<Int> in
                messages /// all messages
                    .flatMap { ///filtering out messages that are not in storage
                        $0.observableEntity()?.asObservable() /// getting observable message from storage
                    }
                    .combineLatest { actualMessages in ///mapping true messages to unread counter
                        let a = actualMessages.filter { !$0.isRead }.count
                        return a
                    }
                    .startWith(0)
            }
        
        
        messageCountDriver
            .map { String($0) }
            .bindTo(unreadMessagesLabel.rx_text)
            .addDisposableTo(bag)
        
        messageCountDriver.map { $0 == 0 }
            .bindTo(unreadMessagesLabel.rx_hidden)
            .addDisposableTo(bag)
    
        ///////
        ///facebook invitation view model
        ///////
//        tableView.rx_itemSelected.filter { $0.row == 6 }
//            .subscribeNext { [weak r = MainRouter.sharedInstance.rootViewController, unowned self] _ in
//                self.invitationViewModel.inviteOn(r!)
//            }
//            .addDisposableTo(bag)
        
//        invitationViewModel.activityDriver
//            .drive(facebookInvitationSpinner.rxex_animating)
//            .addDisposableTo(bag)
        
        invitationViewModel.message.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] message in
                self.showInfoMessage(withTitle: "Message", message)
            }
            .addDisposableTo(bag)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ///SWRevealViewController force adjusts contentInset if UIViewController's view is UIScrollView subclass (which is the case for this class)
        ///We require total control over TableViewLayout so we are canceling SWRevealViewController's rules
        //self.tableView.contentInset = UIEdgeInsetsZero
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
        
        //unreadMessagesLabel.layer.cornerRadius = unreadMessagesLabel.frame.size.height / 2
        self.tableView.contentInset = UIEdgeInsetsZero
    }
    
    @IBAction func selectCityTapped(sender: AnyObject) {
        
        let actionSheet = AHKActionSheet(title: "Select city")
        
        actionSheet.blurTintColor = UIColor(white: 0, alpha: 0.75)
        actionSheet.blurRadius = 8.0;
        actionSheet.buttonHeight = 50.0;
        actionSheet.cancelButtonHeight = 50.0;
        actionSheet.animationDuration = 0.5;
        actionSheet.cancelButtonShadowColor = UIColor(white: 0, alpha: 0.1)
        actionSheet.separatorColor = UIColor(white: 1, alpha: 0.3)
        actionSheet.selectedBackgroundColor = UIColor(white: 0, alpha: 0.5)
        actionSheet.buttonTextAttributes = [ NSFontAttributeName : UIConfiguration.appFontOfSize(17),
            NSForegroundColorAttributeName : UIColor.whiteColor() ]
        actionSheet.disabledButtonTextAttributes = [ NSFontAttributeName : UIConfiguration.appFontOfSize(17),
            NSForegroundColorAttributeName : UIColor.grayColor() ]
        actionSheet.destructiveButtonTextAttributes = [ NSFontAttributeName : UIConfiguration.appFontOfSize(17),
            NSForegroundColorAttributeName : UIColor.redColor() ]
        actionSheet.cancelButtonTextAttributes = [ NSFontAttributeName : UIConfiguration.appFontOfSize(17),
            NSForegroundColorAttributeName : UIColor.whiteColor() ]
        
        for city in viewModel.cities.value {
            
            actionSheet.addButtonWithTitle(city.name, image: nil, type: .Default) { _ in
                self.viewModel.selectedCity(city)
            }
            
        }
        
        actionSheet.show();
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "following segue":
            let controller = (segue.destinationViewController as! UINavigationController).viewControllers.first! as! UserListViewController

            controller.viewModel = UsersListViewModel(mode: .Following)
            
        case "followers segue":
            let controller = (segue.destinationViewController as! UINavigationController).viewControllers.first! as! UserListViewController

            controller.viewModel = UsersListViewModel(mode: .Follower)
        
        case "current user profile":
            let controller = (segue.destinationViewController as! UINavigationController).viewControllers.first! as! UserProfileViewController

            controller.viewModel = UserProfileViewModel(userDescriptor: User.currentUser()!)
            
        case "favorite reports":
            
            let controller = (segue.destinationViewController as! UINavigationController).viewControllers.first! as! FeedCollectionViewController
            
            controller.viewModel = FeedViewModel()
            
            LikeManager.arrayOfLikes.asObservable()
                .subscribeNext { (reports : [Report]) in
                    controller.viewModel.displayData.value = LikeManager.changer()
                }.addDisposableTo(bag)

            
            print(identifier)
            
        default: break

            
        }
    }
 
}