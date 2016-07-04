//
//  InstagramLoginViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/12/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

enum InstagramError : ErrorType {
    case UserCanceled
    case FailedToLoadScreen
}

typealias AccessTokenCallback = (token: String?,error: InstagramError? ) -> Void

class InstagramLoginViewController: UIViewController, UIWebViewDelegate {
    
    private let webView = UIWebView()
    private let callback: AccessTokenCallback
    private weak var presenter: UIViewController?
    
    init(presenter: UIViewController, callback: AccessTokenCallback) {
        self.callback = callback
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    func presentLogin() {
        self.presenter!.presentViewController(UINavigationController(rootViewController: self), animated: true, completion: nil)
    }
    
    func stopLoading() {
        webView.stopLoading()
    }
    
    override func loadView() {
        super.loadView()
        
        let webView = self.webView
        webView.frame = self.view.frame
        webView.scrollView.bounces = false;
        webView.contentMode = UIViewContentMode.ScaleAspectFit;
        webView.delegate = self;
        
        self.view.addSubview(webView)

        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(InstagramLoginViewController.cancel))
        
    }
    
    private var configuration : [String: String] {
        get {
            let configPath = NSBundle.mainBundle().pathForResource("InstagramKit", ofType: "plist")!
            return NSDictionary(contentsOfFile: configPath) as! [String : String]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!
            .filter { ($0.properties!["Domain"] as! String) == "www.instagram.com" }
            .forEach{ NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie($0) }
        
        
        let baseURL = configuration["InstagramKitAuthorizationUrl"]!
        let appClientID = configuration["InstagramKitAppClientId"]!
        let appRedirectURI = configuration["InstagramKitAppRedirectURL"]!
        
        let urlString = baseURL + "?client_id=" + appClientID + "&redirect_uri=" + appRedirectURI + "&response_type=token&scope=" + "basic"
        
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        
        webView.loadRequest(request)
    }

    func cancel() {
        self.callback(token: nil, error: .UserCanceled)
        
        self.presenter!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let redirectURI = configuration["InstagramKitAppRedirectURL"]!
        
        let URLString = request.URL!.absoluteString
        if URLString.hasPrefix(redirectURI) {
            let delimiter = "access_token="
            let components = URLString.componentsSeparatedByString(delimiter)
            if components.count > 1 {
                let accessToken = components.last!
                
                self.callback(token: accessToken, error: nil)
                
                self.presenter!.dismissViewControllerAnimated(true, completion: nil)
            }
            return false;
        }
        return true;

    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.callback(token: nil, error: .FailedToLoadScreen)
        
    }
    
}
