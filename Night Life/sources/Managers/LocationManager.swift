//
//  LocationManager.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/22/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class LocationManager {
    
    static var instance = LocationManager()
    
    private let manager = CLLocationManager()
    private let warningView = NSBundle.mainBundle().loadNibNamed("GeoWarning", owner: nil, options: [:]).first! as! UIView
    
    lazy var lastRecordedLocationObservable: Observable<CLLocation> = {
        
        self.startMonitoring()
        
        let trueLocation = self.manager.rx_didUpdateLocations
            .filter { $0.count > 0 }
            .map { $0.last! }
        
        let fakeLocation = self.fakeLocation.asObservable()

        return Observable.combineLatest(trueLocation, fakeLocation) { trueLoc, fakeLoc in
            return fakeLoc ?? trueLoc
        }
        .shareReplayLatestWhileConnected()
    }()

    var lastRecordedLocation: CLLocation? {
        if let location = fakeLocation.value { return location }
        
        return manager.location
    }
    
    var fakeLocation: Variable<CLLocation?> = Variable(nil)
    
    private func startMonitoring() {
        
        let _ =
        manager.rx_didChangeAuthorizationStatus
            .subscribeNext{ [unowned self, unowned m = manager] e in
                switch (e) {
                    
                case .Denied:
                    self.presentRestrictionView()
                    
                case .NotDetermined: fallthrough    ///here we should present introduction on why we need his location
                case .AuthorizedAlways: fallthrough
                case .AuthorizedWhenInUse: fallthrough
                case .Restricted: fallthrough
                default:
                    ///hide warning window if any present
                    self.hideView()
                    m.startUpdatingLocation()
                    
                    self.setupRegionHandling()
                    self.startRegionMonitoring()
                    
                }

            }
        
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = kCLDistanceFilterNone
    }
    
    func endMonitoring() {
        for r in manager.monitoredRegions {
            manager.stopMonitoringForRegion(r)
        }
    }
    
    private func presentRestrictionView() {
        
        let window = UIApplication.sharedApplication().windows.first!
        
        
        let view = warningView
        view.frame = window.bounds

        window.addSubview(warningView)
        
    }
    
    private func hideView() {
        warningView.removeFromSuperview()
    }
}

extension LocationManager {
    
    private static let lastBaseLocationKey = "com.nightlife.lastBaseLocationKey"
    
    private var lastBaseLocation: CLLocation? {
        get {
            guard let dict = NSUserDefaults.standardUserDefaults().objectForKey(LocationManager.lastBaseLocationKey) as? [String : CLLocationDegrees] else {
                return nil
            }
            
            return CLLocation(latitude: dict["lat"]!, longitude: dict["long"]!)
        }
        set {
            
            if let location = newValue {
            
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                let value = ["lat":lat,"long":lon]
                
                NSUserDefaults.standardUserDefaults().setObject(value, forKey: LocationManager.lastBaseLocationKey)
                
            }
            else {
                NSUserDefaults.standardUserDefaults().setNilValueForKey(LocationManager.lastBaseLocationKey)
            }
            
            
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    private var lastNotificationDate: NSDate? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("com.erminesoft.lastNotificationDate") as? NSDate
        }
        set {
            
            if let date = newValue {
                NSUserDefaults.standardUserDefaults().setObject(date, forKey: "com.erminesoft.lastNotificationDate")
                
            }
            else {
            NSUserDefaults.standardUserDefaults().setNilValueForKey("com.erminesoft.lastNotificationDate")
            }
            
            
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    private func startRegionMonitoring() {
        
        
        let _ =
        lastRecordedLocationObservable
            .filter { [unowned self] newLocation in
                guard let l = self.lastBaseLocation else { return true }
                
                return l.distanceFromLocation(newLocation) > AppConfiguration.recalculateRegionsRadius
            }
            .flatMapLatest { [unowned self] newBaseLocation -> Observable<[Club]> in
                self.lastBaseLocation = newBaseLocation
                
                return ClubsManager
                    .clubListFromRouter(ClubListRouter.Nearest(location: newBaseLocation))
                    .map{ clubs in
                        clubs.filter { $0.location.distanceFromLocation(newBaseLocation) < AppConfiguration.recalculateRegionsRadius }
                    }
            }
            
            .subscribeNext { [unowned m = self.manager] clubs in
                for region in m.monitoredRegions {
                    m.stopMonitoringForRegion(region)
                }
                
                for club in clubs {
                    m.startMonitoringForRegion(CLCircularRegion(center: club.location.coordinate,
                                                                radius: AppConfiguration.acceptableClubRadius,
                                                            identifier: "\(club.id)"))
                }
            }
        
    }
    
    private func setupRegionHandling () {
        
        let _ =
        manager.rx_didEnterRegion
            .filter { [unowned self] _ in
                
                guard let lastDate = self.lastNotificationDate else {
                    return true
                }
                
                return lastDate.timeIntervalSinceNow * -1 > 3600 * 12
                
            }
            .flatMapFirst { region -> Observable<Club> in
                ClubsManager.clubForId(Int(region.identifier)!)
            }
            .subscribeNext { [unowned self] club in
                
                self.lastNotificationDate = NSDate()
                
                let notificatio = UILocalNotification()
                notificatio.alertBody = "You are near \(club.name). Check in and submit a report!"
                notificatio.userInfo = ["clubId" : club.id,
                                        "lat" : club.location.coordinate.latitude,
                                        "long" : club.location.coordinate.longitude]
                
                UIApplication.sharedApplication().presentLocalNotificationNow(notificatio)
        }
        
    }
}
