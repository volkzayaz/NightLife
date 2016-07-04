//
//  NotificationManager.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/29/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

enum NotificationError : ErrorType {
    case NoAuthorizedUser
    case NoTokenStored
}

class NotificationManager {

    private static let deviceTokenKey = "com.nighlife.deviceTokenKey"
    
    static func setup(launchOptions: [NSObject : AnyObject]?) {
        
        let notificationSettings = UIUserNotificationSettings( forTypes: [.Alert, .Sound], categories: nil )
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        if NSUserDefaults.standardUserDefaults().objectForKey(deviceTokenKey) == nil {
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
        
        
        if let localNotification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification
        {
            self.handleLocalNotification(localNotification)
        }
        
        //let fakePayload = ["data": ["type" : 5, "club_id" : 4] ]
        
        if let remoteNotificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject]
        {
            self.handleRemoteNotification(remoteNotificationPayload, applicationState: .Inactive)
        }
        
    }
    
    static func handleDeviceToken(tokenData: NSData) {
        
        NSUserDefaults.standardUserDefaults().setObject(tokenData, forKey: deviceTokenKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        do { try saveDeviceToken() }
        catch { print("Can't save token now. Will try later") }
        
    }
    
    static func saveDeviceToken() throws {
        
        guard let _ = AccessToken.token else {
            throw NotificationError.NoAuthorizedUser
        }
        
        guard let token = NSUserDefaults.standardUserDefaults().objectForKey(deviceTokenKey) as? NSData else {
            throw NotificationError.NoTokenStored
        }
        
        Alamofire.request(UserRouter.LinkDeviceToken(deviceToken: token))
            .responseJSON { response in
                
                print(response.result.value)
            }
        
    }
    
    static func flushDeviceToken() {
        
          Alamofire.request(UserRouter.UnLinkDeviceToken)
            .responseJSON { response in
                print(response.result.value)
        }
        
    }
    
}

enum NightlifeNotificationType {
    
    case NewRequests
    case NewCheckin
    case VenueIsHot(clubId: Int)
    case VenueNews
    
    case NearClub(clubId: Int, location: CLLocation)
    
    init?(type: Int, clubId: Int? = nil, location: CLLocation? = nil) {
        
        guard 1...5 ~= type else { return nil }
        
        switch type {
            
        case 1:
            self = .NewRequests
            
        case 2:
            self = .NewCheckin
            
        case 3:
            guard let id = clubId else { return nil }
            self = .VenueIsHot(clubId: id)
            
        case 4:
            self = .VenueNews
            
        case 5:
            guard let id = clubId, let l = location else { return nil }
            self = .NearClub(clubId: id, location: l)
            
        default:
            return nil
            
        }
        
    }
    
}

extension NotificationManager {
    
    static func handleLocalNotification(localNotification: UILocalNotification) {
        if let clubId           = localNotification.userInfo?["clubId"] as? Int,
           let latitude         = localNotification.userInfo?["lat"] as? CLLocationDegrees,
           let longitude        = localNotification.userInfo?["long"] as? CLLocationDegrees,
           let notificationType = NightlifeNotificationType(type: 5,
                                                            clubId: clubId,
                                                            location: CLLocation(latitude: latitude, longitude: longitude)) {
        
            MainRouter.sharedInstance.routForNotification(notificationType, verificationMessage: localNotification.alertBody)
            
        }
    }
    
    static func handleRemoteNotification(notificationPayload: [NSObject : AnyObject], applicationState: UIApplicationState) {
        
        guard let data = notificationPayload["data"] as? [NSObject : AnyObject],
              let payload = notificationPayload["aps"] as? [NSObject : AnyObject],
              let typeNumber = data["type"] as? Int,
              let alertString = payload["alert"] as? String,
              let notification = NightlifeNotificationType(type: typeNumber, clubId: data["club_id"] as? Int) else {
                assert(false, "Error retreiving notification type from \(notificationPayload)")
                return
        }
        
        ///if app was active when notification arrived we'll present popup with alert string
        let verificationMessage: String? = applicationState == .Active ? alertString : nil
        
        MainRouter.sharedInstance.routForNotification(notification, verificationMessage: verificationMessage)
        
    }
    
}