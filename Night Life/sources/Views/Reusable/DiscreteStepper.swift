//
//  DiscreteStepper.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

class DiscreetStepper<T : CustomStringConvertible> : UIView {
    
    private(set) var selectedOption : T?
    
    var minimumColor : UIColor = UIColor.greenColor() {
        didSet {
           minimumView.backgroundColor = minimumColor
        }
    }

    var maximumColor : UIColor = UIColor.yellowColor() {
        didSet {
            maximumView.backgroundColor = maximumColor
        }
    }
    
    var thumbImage : UIImage? {
        didSet {
            thumbImageView.image = thumbImage
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    private let thumbImageView = UIImageView(image: UIImage(named: "report_check"))
    private let minimumView = UIView()
    private let maximumView = UIView()
    private var marks : [(UIImageView, UILabel, T)] = []
    private let sideOffset : CGFloat = 20.0

    func addOptions
        (options: [T]) {
            
            //self.backgroundColor = UIColor.yellowColor()
            
            let itemsCount = options.count
            guard itemsCount > 1 else {
                print("Can't add options without at least two options")
                return
            }
        
            selectedOption = options.first!

            self.thumbImageView.center = CGPoint(x: sideOffset, y: 0)
            
            minimumView.backgroundColor = minimumColor
            maximumView.backgroundColor = maximumColor
            
            self.subviews.forEach { $0.removeFromSuperview() }
            self.marks.removeAll()
            
            self.addSubview(minimumView)
            self.addSubview(maximumView)
            
            for option in options {
                
                let imageView = UIImageView(frame: CGRectMake(0, 0, 10, 10))
                imageView.image = UIImage(named: "tor")
                self.addSubview(imageView)
                
                let label = UILabel()
                label.text = option.description.stringByReplacingOccurrencesOfString(" ", withString: "\n")
                label.font = UIConfiguration.appSecondaryFontOfSize(10)
                label.textColor = UIColor.whiteColor()
                label.numberOfLines = 2
                label.textAlignment = .Center
                self.addSubview(label)
                
                self.marks.append((imageView,label,option))
                
            }
            
            self.addSubview(thumbImageView)
            
        }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateFrames()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInView(self)
        
        self.thumbImageView.center.x = touchLocation.x
        self.updateFrames()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchLocation = touches.first!.locationInView(self)
        
        let nextCenetreMark = marks.reduce(marks.first!) { (winnerMark: (UIImageView,UILabel,T), challengerMark) -> (UIImageView,UILabel,T) in
            
            let winnerDistance : CGFloat = abs(winnerMark.0.center.x - touchLocation.x)
            let challengerDistance : CGFloat = abs(challengerMark.0.center.x - touchLocation.x)
            
            return winnerDistance > challengerDistance ?
                challengerMark : winnerMark
            
        }
        
        self.selectedOption = nextCenetreMark.2
        
        UIView.animateWithDuration(0.4) {
            self.thumbImageView.center.x = nextCenetreMark.0.center.x
            
            self.updateFrames()
        }
    }
    
    func updateFrames() {
        let superViewSize = self.frame.size
        self.thumbImageView.center.y = superViewSize.height / 2 + 10
        
        let thumbCenter = self.thumbImageView.center
        let lineHeight : CGFloat = 3.0
        
        minimumView.frame = CGRect(x: sideOffset,
            y: thumbCenter.y - lineHeight / 2,
            width: thumbCenter.x - sideOffset,
            height: lineHeight)
        
        maximumView.frame = CGRect(x: thumbCenter.x,
            y: thumbCenter.y - lineHeight / 2,
            width: superViewSize.width - thumbCenter.x - sideOffset,
            height: lineHeight)
        
        for (index, mark) in marks.enumerate() {
            
            let width : Float = Float(superViewSize.width) - Float(2.0 * sideOffset)
            let x = width * Float(index) / Float(marks.count - 1) + Float(sideOffset)
            
            mark.0.center = CGPoint(x: CGFloat(x), y: thumbCenter.y)
            mark.1.sizeToFit()
            mark.1.center = CGPoint(x: CGFloat(x), y: thumbCenter.y - 25)
            
        }
        
    }
    
}
