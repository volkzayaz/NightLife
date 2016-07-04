//
//  GradientBar.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/3/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

class GradientBar : UINavigationBar {
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        let barSize = CGSize(width: UIApplication.sharedApplication().windows.first!.frame.size.width, height: 64);
        
        let gradientLayer = UIConfiguration.naviagtionBarGradientLayer(forSize: barSize)
        
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        self.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), forBarMetrics: .Default)
        
        UIGraphicsEndImageContext();

        self.titleTextAttributes = [
            NSFontAttributeName : UIConfiguration.appSecondaryFontOfSize(19),
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
    }
    
}

class GradientView: UIView {
    
    private let gradientLayer = UIConfiguration.gradientLayer(UIColor(white: 0, alpha: 0.5), to: UIColor(white: 0, alpha: 1))
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        gradientLayer.cornerRadius = 0
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = self.bounds
    }
    
}