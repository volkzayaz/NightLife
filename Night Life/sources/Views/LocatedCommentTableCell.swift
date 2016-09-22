//
//  LocatedCommentTableCell.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa

import DateTools
import CoreLocation

class LocatedCommentTableCell : UITableViewCell{
    
   
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentBodyLabel: UILabel!
    
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    private let geoCoder = CLGeocoder()
    
    
    func setLocatedComment(comment: Comment) {
        
        commentBodyLabel.text = comment.body
        dateLabel.text = NSDateFormatter.localizedStringFromDate(comment.createdDate, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        dayOfWeekLabel.text = TodayDayManager.dayOfWeekText()
        
        geoCoder.reverseGeocodeLocation(comment.location!)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            let placeMark: CLPlacemark! = placeArray.first
            if let street = placeMark.addressDictionary?["Thoroughfare"] as? String
            {
                self.streetLabel.text = street
                
            }
            
            if let city = placeMark.addressDictionary?["City"] as? String
            {
                self.cityLabel.text = city
                
            }
            
            
        }
        
    }
    
    
}