//
//  LoginViewController.swift
//  GlobBar
//
//  Created by admin on 12.05.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class SignInViewController: UIViewController {

    var viewModel: SignInViewModel!
    
    private let bag = DisposeBag()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func back(sender: AnyObject) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (viewModel == nil) { fatalError("ViewModel must be instantiated prior to using SignupViewController") }
        
        viewModel.indicator.asObservable()
            .bindTo(spinner.rxex_animating)
            .addDisposableTo(bag)
        
        viewModel.errorMessage.asObservable()
            .filter { $0 != nil }.map { $0! }
            .subscribeNext { [unowned self] message in
                self.showInfoMessage(withTitle: "Error", message)
            }
            .addDisposableTo(bag)
        
        let emailValidation = emailTextField.rx_text.map { $0.isValidEmail() }
        let passwordValidation = passwordTextField.rx_text.map { $0.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 }
        
        Observable.combineLatest(emailValidation, passwordValidation)
        { $0 && $1}
            .bindTo(loginButton.rx_enabled)
            .addDisposableTo(bag)
        
        loginButton.rx_tap.subscribeNext { [unowned self] _ in
            self.viewModel.signInAction(self.emailTextField.text!,
                password: self.passwordTextField.text!)
            
            }
            .addDisposableTo(bag)
        
        viewModel.backSignal.asObservable()
            .filter { $0 != nil }.map { $0! }
            .subscribeNext { [unowned self] _ in
                self.back(self)
            }
            .addDisposableTo(bag)
        

    }
    
}
