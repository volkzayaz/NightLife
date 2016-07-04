//
//  TextBoxController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/31/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TextBoxController : UIViewController {
    
    private static let transitionAnimator = CommentsTransitionAnimator()
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.font = UIConfiguration.appSecondaryFontOfSize(14)
            textView.textColor = UIColor.blackColor()
        }
    }
    
    
    @IBOutlet weak var positiveButton: UIButton!
    
    @IBOutlet weak var negativeButton: UIButton! {
        didSet {
            negativeButton.setTitleColor(UIColor(fromHex: 0x7D7C7B), forState: .Normal)
        }
    }
    
    var viewModel: TextBoxViewModel!
    
    private let bag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = TextBoxController.transitionAnimator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil { fatalError("Can't use TextBoxController without viewModel") }
        
        positiveButton.rx_tap.map { [unowned self] _ in
            return self.textView.text
        }
        .bindTo(viewModel.text)
        .addDisposableTo(bag)
        
        textView.text = viewModel.displayText
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
        textView.select(self)
        textView.selectedRange = NSRange(location: 0, length: textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

class TextBoxViewModel {
    
    let text: Variable<String?> = Variable(nil)
    let displayText: String
    init(displayText: String) {
        self.displayText = displayText
    }
}


class CommentsTransitionAnimator : NSObject, UIViewControllerTransitioningDelegate {

    @objc func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CommentsEnteringAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CommentsLeavingAnimator()
    }
    
    
    class CommentsEnteringAnimator : NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            return 0.5
        }
        
        func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            
            let containerView = transitionContext.containerView()!
            
            let containerBounds = containerView.bounds
            
            toViewController.view.frame = containerBounds;
            
            let overlay = UIView(frame: containerBounds)
            overlay.backgroundColor = UIColor.blackColor()
            overlay.alpha = 0
            
            containerView.addSubview(overlay)
            containerView.addSubview(toViewController.view)
            
            toViewController.view.alpha = 0.0
            toViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3)
            
            let duration = self.transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration / 2.0) {
                toViewController.view.alpha = 1.0;
                overlay.alpha = 0.5;
            }
            
            let damping: CGFloat = 0.55
            
            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 1 / damping, options: [], animations: {
                toViewController.view.transform = CGAffineTransformIdentity;
            }) { (finished) in
                transitionContext.completeTransition(true)
            }
            
        }
        
    }
    
    class CommentsLeavingAnimator : NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            return 0.3
        }
        
        func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            
            guard let containerView = transitionContext.containerView(),
                  let overlay = containerView.subviews.first,
                  let textBoxView = containerView.subviews.last where overlay.alpha == 0.5 else {
                    
                    assert(false, "View hierarchy changed, cant perform smooth transition")
                    return
            }
            
            let duration = self.transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration, animations: {
                overlay.alpha = 0.0;
                
                textBoxView.alpha = 0.0
                textBoxView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }) { (finished) in
                transitionContext.completeTransition(true)
            }
            
        }
        
    }
    
}