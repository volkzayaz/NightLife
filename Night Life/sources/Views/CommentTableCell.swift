//
//  CommentTableCell.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 16.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa

import DateTools
import CoreLocation

class CommentTableCell : UITableViewCell{
    
    @IBOutlet weak var coomentLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
   
    @IBOutlet weak var locationStreetLabel: UILabel!
    private let geoCoder = CLGeocoder()
   
   
    func setComment(comment: Comment) {
        
        coomentLabel.text = comment.body
        createdDate.text = NSDateFormatter.localizedStringFromDate(comment.createdDate, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        createdLabel.text = TodayDayManager.dayOfWeekText()
        
        geoCoder.reverseGeocodeLocation(comment.location!)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            let placeMark: CLPlacemark! = placeArray.first
            if let street = placeMark.addressDictionary?["Thoroughfare"] as? String
            {
                self.locationStreetLabel.text = street
               
            }
        
            if let city = placeMark.addressDictionary?["City"] as? String
            {
                self.locationLabel.text = city
               
            }
            
            
        }
        
    }
    
    
}