//
//  AppDelegate.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    ///FIXME: Profile application for memmory leaks
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Crashlytics.self])
        
        UIConfiguration.setUp()
        
        MainRouter.sharedInstance.initialRoutForWindow(window)
        
        ///should be called after initial rout is established.
        ///application might have been launched from notification
        NotificationManager.setup(launchOptions)
        
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    ///notifications
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        NotificationManager.handleDeviceToken(deviceToken)
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NotificationManager.handleLocalNotification(notification)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(application.applicationState)
        
        NotificationManager.handleRemoteNotification(userInfo, applicationState: application.applicationState)
    }
    
    //applicatio
}

