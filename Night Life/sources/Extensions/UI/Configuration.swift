//
//  Configuration.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/22/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import CoreLocation

struct UIConfiguration {
    
    static func setUp() {
        ///setup any appearence proxies if neccesary
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
                NSFontAttributeName : UIConfiguration.appSecondaryFontOfSize(16),
                NSForegroundColorAttributeName : UIColor.whiteColor()
            ],
            forState: .Normal)
        
    }

    static func stringFromDate(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "HH:mma ccc c LLL y"
        
        var string = dateFormatter.stringFromDate(date)
        
        //  to lowercase PM/AM part of string
        let startIndex = string.startIndex.advancedBy(5)
        let endIndex = string.rangeOfString("M")?.endIndex
     
        let partPM_AMRange = Range<String.Index>(startIndex...endIndex!)
        
        let partPM_AM = string.substringWithRange(partPM_AMRange).lowercaseString
        
        //  to upercase PM/AM part of string
        let startIndex2 = endIndex!.advancedBy(1)
        let endIndex2 = startIndex2.advancedBy(3)
        
        let partDayOfWeekRange = Range<String.Index>(startIndex2...endIndex2)
        
        let partDayOfWeek = string.substringWithRange(partDayOfWeekRange).uppercaseString
        
        // Replace parts in original string
        string.replaceRange(partPM_AMRange, with: partPM_AM)
        string.replaceRange(partDayOfWeekRange, with: partDayOfWeek)
        
        return string
    }
    
    
    /**
     * Roboto-regular
     */
    static func appFontOfSize(size: CGFloat) -> UIFont {
        
        return UIFont(name: "Roboto-Regular", size: size)!
        
    }
    
    /**
     * Raleway-regular
     */
    static func appSecondaryFontOfSize(size: CGFloat) -> UIFont {
        
        return UIFont(name: "Raleway-Regular", size: size)!
        
    }
    
    /**
     * Raleway-light
     */
    static func appSecondaryLightFontOfSize(size: CGFloat) -> UIFont {
        
        return UIFont(name: "Raleway-Light", size: size)!
        
    }
    
    static func naviagtionBarGradientLayer(forSize size: CGSize) -> CALayer {

        let to = UIColor(fromHex: 0xc53e03);
        let from = UIColor(fromHex: 0xf39200);
        
        let layer = CAGradientLayer()
            
        layer.colors = [from.CGColor, to.CGColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.frame = CGRect(origin: CGPointZero, size: size)
        layer.opacity = 0.38
        
        let bottomLayer = CALayer()
        
        bottomLayer.backgroundColor = UIColor(fromHex: 0xf37000).CGColor
        bottomLayer.frame = layer.frame
        bottomLayer.addSublayer(layer)
        
        return bottomLayer;
    }
    
    static func gradientLayer(from: UIColor, to: UIColor) -> CALayer {
        let layer = CAGradientLayer()
        
        layer.colors = [from.CGColor, to.CGColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.cornerRadius = 4
        
        return layer
    }
    
}

struct AppConfiguration {
    
    /**
     *  If user is within this distance from club it is assumed that user is inside the club
     */
    static let acceptableClubRadius: CLLocationDistance = 100
    
    /**
     *  App is monitoring nearby clubs for user. If user moved within this value from location where monitoring was set up,
     *  app will recalculate it's monitored regions
     */
    static let recalculateRegionsRadius: CLLocationDistance = 12000
    
    static let maximumRecordedVideoDuration: NSTimeInterval = 10
    
    static let termsAndConditionsLink: String = "http://nightlife.gotests.com/terms_and_conditions/"
    
    /**
     * This date formatter matches format of dat that is passed from nightlife servers
     */
    static func dateFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return formatter
    }
    
}

extension CLLocationDistance {
    
    var metersToMiles: Double {
        return self / 1609.344
    }
    
}