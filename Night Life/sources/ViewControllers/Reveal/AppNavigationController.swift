//
//  AppNavigationController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/29/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController

class AppNavigationController : UINavigationController, UINavigationControllerDelegate {
    
    override func loadView() {
        super.loadView()
        
        let barSize = CGSize(width: UIApplication.sharedApplication().windows.first!.frame.size.width, height: 64);
        
        let gradientLayer = UIConfiguration.naviagtionBarGradientLayer(forSize: barSize)
        
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        self.navigationBar.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), forBarMetrics: .Default)
        
        UIGraphicsEndImageContext();
        
        self.navigationBar.titleTextAttributes = [
            NSFontAttributeName : UIConfiguration.appSecondaryFontOfSize(19),
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
        self.navigationBar.tintColor = UIColor.whiteColor()
        
        self.delegate = self
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        guard let first = navigationController.viewControllers.first,
              let revealController = self.revealViewController()
        else { return }
        
        if viewController === first {
            
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .Plain, target: revealController, action: #selector(SWRevealViewController.revealToggle))
            viewController.navigationItem.leftBarButtonItem = barButtonItem
            
        }
    }
    
}

