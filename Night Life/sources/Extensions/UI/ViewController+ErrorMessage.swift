//
//  ViewController+ErrorMessage.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/26/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import ObjectiveC
import RxSwift

typealias MessageCallback = () -> Void
var AssociatedObjectHandle: UInt8 = 0

extension UIViewController {
    
    var viewModelTwo: OriginalViewModel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? OriginalViewModel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }

        if self !== UIViewController.self {
            return
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = #selector(UIViewController.viewDidLoad)
            let swizzledSelector = #selector(UIViewController.nsh_viewDidLoad)
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }

    
    func nsh_viewDidLoad() {
        self.nsh_viewDidLoad()
        
        if let new = viewModelTwo {
            
            new.errorMessage.asDriver()
                .filter { $0 != nil }.map { $0! }
                .driveNext { [unowned self] message in
                    self.showInfoMessage(withTitle: "Error", message)
            }
            
        }

    }

    
    func showInfoMessage(withTitle title:String,_ text: String,_ buttonText: String = "Ok" , _ callback: MessageCallback? = nil) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: buttonText, style: .Default) { _ in
            if let callback = callback {
                callback()
            }
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showSimpleQuestionMessage(withTitle title:String, _ question: String, _ positiveCallback: MessageCallback? = nil, _ negativeCallback: MessageCallback? = nil)
    {
        let alertController = UIAlertController(title: title, message: question, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: .Cancel) { _ in
            if let callback = negativeCallback {
                callback()
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default) { _ in
            if let callback = positiveCallback {
                callback()
            }
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
}
