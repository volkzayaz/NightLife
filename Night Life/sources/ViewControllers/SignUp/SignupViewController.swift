//
//  SignupViewController.swift
//  GlobBar
//
//  Created by admin on 12.05.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SWRevealViewController
import QuartzCore

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var viewModel: SignUpViewModel!
    
    private let bag = DisposeBag()
    
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
        
        let emailValidation = emailField.rx_text.map { $0.isValidEmail() }
        let usernameValidation = usernameField.rx_text.map { $0.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 }
        let passwordValidation = passwordField.rx_text.map { $0.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 }
        
        
        Observable.combineLatest(emailValidation, usernameValidation, passwordValidation)
        { $0 && $1 && $2 }
            .bindTo(signUpButton.rx_enabled)
            .addDisposableTo(bag)
        
        signUpButton.rx_tap.subscribeNext { [unowned self] _ in
            self.viewModel.signUpAction(self.emailField.text!,
                username: self.usernameField.text!,
                password: self.passwordField.text!)
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

extension String {
    
    func isValidEmail() -> Bool {
        
        let emailRegex = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(self)
        
    }
    
}
