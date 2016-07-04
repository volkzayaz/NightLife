//
//  RootViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/5/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController
import CoreLocation

/**
 *  Responsible for routing between Main Application controller and Authorization controller
*/

class MainRouter: NSObject {
    
    static var sharedInstance = MainRouter()
    
    private weak var window: UIWindow?
     var rootViewController: UINavigationController {
        get {
            return window?.rootViewController as! UINavigationController
        }
    }
    
    private var authorizationController: AuthorizationViewController {
        get {
            return mainStoryboard.instantiateViewControllerWithIdentifier("AuthorizationController") as! AuthorizationViewController
        }
    }
    
    private lazy var mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    private lazy var topControllerStoryboard = UIStoryboard(name: "ClubList", bundle: nil)
    private lazy var clubFeedStoryboard = UIStoryboard(name: "ClubFeed", bundle: nil)
    
    func initialRoutForWindow(window: UIWindow?) {
        self.window = window
        window?.makeKeyAndVisible()
        
        rootViewController.navigationBarHidden = true
        
        if let _ = AccessToken.token {
            mainAppScreenRout(animated: false)
        }
        else {
            authorizationRout()
        }
    }
   
    func mainAppScreenRout(animated animated: Bool = false) {
        
        //TODO: work on transition animation
        let revealController = self.mainStoryboard.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        revealController.delegate = self
        
        let sideViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("side view controller")
        revealController.setRearViewController(sideViewController, animated: false)
        
        let topViewController = self.topControllerStoryboard.instantiateInitialViewController()!
        revealController.setFrontViewController(topViewController, animated: false)
        
        self.rootViewController.setViewControllers([revealController], animated: animated)
    }
    
    func authorizationRout(animated animated: Bool = false) {
        
        let controller = mainStoryboard.instantiateViewControllerWithIdentifier("AuthorizationController")
        rootViewController.setViewControllers([controller], animated: animated)
        
    }
}

extension MainRouter { ///Notification Routes
    
    func routForNotification(notification: NightlifeNotificationType, verificationMessage: String?) {
        
        guard let _ = AccessToken.token else {
            print("WARNING: Will do nothing with notification rout, since there're no logged in user")
            return
        }
        
        var routClosure: ( ()->() )? = nil
        
        switch notification{
            
        case .NewRequests:
            routClosure = { self.newRequestsNotificationRout() }
            
        case .VenueIsHot(let clubId):
            routClosure = { self.venueIsHotNotificationRout(clubId) }
            
        case .NearClub(let clubId, let location):
            routClosure = { self.closeToVenueNotificationRout(clubId, venueLocation: location) }
            
        case .NewCheckin: fallthrough
        case .VenueNews: break;
            
        }
        
        if let message = verificationMessage { /// we need do present popup with message prior to rout
            
            guard let rout = routClosure else { ///if there're no routs, just fire popup and forget
                revealViewController().showInfoMessage(withTitle: "", message, "Got it")
                return
            }
            
            ///asking question on whether we need to perform rout
            revealViewController().showSimpleQuestionMessage(withTitle: "", message, { 
                rout()
            })
        }
        else {
            
            ///performin rout if any
            routClosure?()
            
        }
        
    }
    
    private func revealViewController() -> SWRevealViewController {
        
        guard let revealController = rootViewController.viewControllers.first as? SWRevealViewController else {
            fatalError("Please update logic for updated controllers hierarchy")
        }
        
        return revealController
    }
    
    private func newRequestsNotificationRout() {
        
        self.revealViewController().rearViewController.performSegueWithIdentifier("followers segue", sender: nil)
        
    }
 
    private func closeToVenueNotificationRout(clubId: Int, venueLocation: CLLocation) {
        
        guard let navigationController = revealViewController().frontViewController as? UINavigationController,
              let feedController = clubFeedStoryboard.instantiateInitialViewController() as? ClubFeedViewController else {
            fatalError("Cannot present 'close to venue' root without navigation controller")
        }
        
        let _ =
        LocationManager.instance.lastRecordedLocationObservable
            .take(1)
            .subscribeNext { location in
                let viewModel = ClubFeedViewModel(club: Club(id: clubId),
                    startFromCheckin: location.distanceFromLocation(venueLocation) < AppConfiguration.acceptableClubRadius)
                
                feedController.viewModel = viewModel
                
                navigationController.setViewControllers([feedController], animated: false)
            }
        
    }
    
    private func venueIsHotNotificationRout(clubId: Int) {
        
        guard let navigationController = revealViewController().frontViewController as? UINavigationController,
            let feedController = clubFeedStoryboard.instantiateInitialViewController() as? ClubFeedViewController else {
                fatalError("Cannot present 'venue is hot' root without navigation controller")
        }
        
        let viewModel = ClubFeedViewModel( club: Club(id: clubId) )
        feedController.viewModel = viewModel
        
        navigationController.setViewControllers([feedController], animated: false)
        
    }
}

extension MainRouter: SWRevealViewControllerDelegate {

    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {

        if let controller = revealController.frontViewController as? UINavigationController,
           let topController = controller.childViewControllers.last {
            
            topController.view.userInteractionEnabled = position != FrontViewPosition.Right
        }
    }
}

