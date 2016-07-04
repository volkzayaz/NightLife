//
//  CheckView.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/5/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

class CheckButton : UIButton {
    
    private var titleEdgeInset : UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    override func intrinsicContentSize() -> CGSize {
        var s = super.intrinsicContentSize()
        s.width += titleEdgeInset.left
        return s
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setImage(UIImage(named: "Off"), forState: .Normal)
        self.setImage(UIImage(named: "On"), forState: .Selected)
        
        self.addTarget(self, action: #selector(CheckButton.action), forControlEvents: .TouchUpInside)
        
        self.titleEdgeInsets = titleEdgeInset
    }
    
    func action() {
        
        self.selected = !self.selected
        
    }
    
}
