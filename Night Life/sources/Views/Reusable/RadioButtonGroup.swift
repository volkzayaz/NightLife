//
//  RadioButtonGroup.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RadioButton

class RadioButtonGroup<T : CustomStringConvertible>
    : UIView {
    
    var selectedOption: T? {
        get {
            return pairs.filter { $0.button.selected }.first?.option
        }
    }
    
    typealias Pair = (button: RadioButton, option: T)
    private var pairs : [Pair] = []
    
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    func addOptions
        (options: [T]) {
            
            let itemsCount = options.count
            guard itemsCount > 1 else {
                print("Can't add options without at least two options")
                return
            }
            
            
            let rowsCount: Int = (itemsCount + 1) / 2
            
            var rightColumnButtons : [RadioButton] = []
            var leftColumnButtons : [RadioButton] = []
            var spacingViews : [UIView] = []
            
            ///adding left column buttons and spacings between them
            for i in 0...rowsCount - 1
            {
                let spacingView = createSpacingViewBefore(leftColumnButtons.last, heightMasterSpacingView: spacingViews.last)
                spacingViews.append(spacingView)
                
                leftColumnButtons.append(createLeftColumnRadioButtonAfter(spacingView))
                
                if i == rowsCount - 1 {
                    spacingViews.append(createSpacingViewAfter(leftColumnButtons.last, heightMasterSpacingView: spacingView))
                }
            }
            
            ///adding right column buttons
            for i in rowsCount...itemsCount - 1 {
                
                let centerNeighbour = leftColumnButtons[i - rowsCount]
                rightColumnButtons.append(createRightColumnRadioButton(centerNighbour: centerNeighbour, upperNeighbour: rightColumnButtons.last))
                
            }
            
            ///settings raadio group
            rightColumnButtons.first!.groupButtons = rightColumnButtons.suffixFrom(1) + leftColumnButtons
            
            ///setting titles
            zip((leftColumnButtons + rightColumnButtons), options).forEach { input in
                    input.0.setTitle(input.1.description, forState: .Normal)
                    pairs.append(input)
                }
            
//            ///set default selected value
//            rightColumnButtons.first?.setSelected(true)
    }
    
    ///spacing views methods
    
    func createSpacingViewBefore(radioButton: RadioButton?, heightMasterSpacingView: UIView?) -> UIView {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        if let rb = radioButton {
            
            guard let masterView = heightMasterSpacingView else { assert(false, "master View must be passed"); return UIView() }
            
            ///should set top constraint to radio button bottom = 0
            ///should set leading constraint equal to radioButton leading
            ///should set equal heights + equal widths with masterView
            
            let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: rb, attribute: .Bottom, multiplier: 1, constant: 0)
            let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: rb, attribute: .Leading, multiplier: 1, constant: 0)
            let equalWidthsConstraint = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: masterView, attribute: .Width, multiplier: 1, constant: 0)
            let equalHeightsConstraint = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: masterView, attribute: .Height, multiplier: 1, constant: 0)
            
            self.addConstraints([topConstraint, leadingConstraint, equalHeightsConstraint, equalWidthsConstraint])
            
        }
        else {
            
            ///it is the very first spacing view
            ///should set up fixed width, spacing to superview leading, zero spacing to superview top
            let widthConstraint = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 10)
            let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .LeadingMargin, multiplier: 1, constant: 0)
            let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy:.Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
            
            self.addConstraints([leadingConstraint,topConstraint])
            view.addConstraint(widthConstraint)
        }
        
        return view
    }
    
    func createSpacingViewAfter(radioButton: RadioButton?, heightMasterSpacingView: UIView) -> UIView {
        
        let view = createSpacingViewBefore(radioButton, heightMasterSpacingView: heightMasterSpacingView)
        
        ///add bottom to superview constraint
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        
        self.addConstraint(bottomConstraint)
        
        return view
    }
    
    ///radio button methods
    
    func createLeftColumnRadioButtonAfter(spacingView: UIView) -> RadioButton {
        let rb = constructRadioButton()
        
        ///set top constraint equal to spacing view
        ///set leading equal to leading of spacing view
        let topConstraint = NSLayoutConstraint(item: rb, attribute: .Top, relatedBy: .Equal, toItem: spacingView, attribute: .Bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: rb, attribute: .Leading, relatedBy: .Equal, toItem: spacingView, attribute: .Leading, multiplier: 1, constant: 0)
        
        self.addConstraints([topConstraint, leadingConstraint])
        
        return rb
    }
    
    func createRightColumnRadioButton(centerNighbour centerNeighbour: RadioButton, upperNeighbour: RadioButton?) -> RadioButton {
        
        let rb = constructRadioButton()
        
        ///center with centerNeighbour
        ///set trailing to superview as GreaterThanOrEqual to constant
        ///set spacing with centerNeighbour as GreaterThanOrEqual to constant
        ///if upper neighbour exist => set equal leadings 
        ///else set trailing constraint with low priority to fixed constant
        
        let centerConstraint = NSLayoutConstraint(item: rb, attribute: .CenterY, relatedBy: .Equal, toItem: centerNeighbour, attribute: .CenterY, multiplier: 1, constant: 0)
        let trailingGreaterConstraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .GreaterThanOrEqual, toItem: rb, attribute: .Trailing, multiplier: 1, constant: 8)
        trailingGreaterConstraint.priority = 1000
        let spacingConstrait = NSLayoutConstraint(item: rb, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: centerNeighbour, attribute: .Trailing, multiplier: 1, constant: 8)
        
        let equalWidthConstraint = NSLayoutConstraint(item: rb, attribute: .Width, relatedBy: .Equal, toItem: centerNeighbour, attribute: .Width, multiplier: 1, constant: 0)
        equalWidthConstraint.priority = 500
        
        var variableConstraint: NSLayoutConstraint? = nil
        
        if let upper = upperNeighbour {
            
            variableConstraint = NSLayoutConstraint(item: rb, attribute: .Leading, relatedBy: .Equal, toItem: upper, attribute: .Leading, multiplier: 1, constant: 0)
            variableConstraint!.priority = 1000
        }
        else {
            variableConstraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: rb, attribute: .Trailing, multiplier: 1, constant: 8)
            variableConstraint!.priority = 100
        }
        
        self.addConstraints([centerConstraint, trailingGreaterConstraint, spacingConstrait, equalWidthConstraint,variableConstraint!])
        
        return rb
    }
    
    func constructRadioButton() -> RadioButton {
        
        let button = DaButton()

        ///TODO: move label font to configuration and adjust it there based on screen size
        
        button.titleLabel?.font = UIConfiguration.appSecondaryFontOfSize(14)
        button.titleLabel?.lineBreakMode = .ByWordWrapping
        button.contentHorizontalAlignment = .Left
        
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        
        button.setImage(UIImage(named: "option_off"), forState: .Normal)
        button.setImage(UIImage(named: "option_on"), forState: .Selected)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(button)
        
        return button
    }
}



class DaButton : RadioButton {
    
    private var titleEdgeInset : UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    init() {
        super.init(frame: CGRectZero)
        
        self.titleEdgeInsets = titleEdgeInset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize {
        var s = super.intrinsicContentSize()
        s.width += titleEdgeInset.left
        return s
    }
    
}
 