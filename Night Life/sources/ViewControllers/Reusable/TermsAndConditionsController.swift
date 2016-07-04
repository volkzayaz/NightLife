//
//  TermsAndConditionsController.swift
//  GlobBar
//
//  Created by Vlad Soroka on 4/29/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

class TermsAndConditionsController : UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Terms & Conditions"
        
        if let url = NSURL(string: AppConfiguration.termsAndConditionsLink) {
            webView.loadRequest(NSURLRequest(URL: url))
        }
        
    }
    
}