//
//  MyProfile.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController
import MBCircularProgressBar

import RxSwift
import RxCocoa

import Alamofire

class UserProfileViewController : UIViewController {
    
    var viewModel: UserProfileViewModel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var pointsCountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var editUsernameButton: UIButton!
    
    @IBOutlet var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var updateProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var followActionsButton: UIButton!
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil { fatalError("ViewModel must be initialised prior to using ViewController") }
        
        if self.navigationController?.viewControllers.indexOf(self)! != 0 {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        let editingModeDriver = viewModel.editingState.asDriver()
        
        editingModeDriver.driveNext { [unowned self] state in
            var barButtonItem: UIBarButtonItem? = nil
            switch state {
            case .ShowConfirmation:
                barButtonItem = self.saveBarButtonItem
            case .ShowEditing:
                barButtonItem = self.editBarButtonItem
                
            case .NoEditing: break;
            }
            
            self.navigationItem .setRightBarButtonItem(barButtonItem, animated: true)
        }
        .addDisposableTo(bag)
        
        let showConfirmationDriver = editingModeDriver.map { $0 != UserProfileEditingState.ShowConfirmation }
        let showEditingDriver = editingModeDriver.map { $0 != UserProfileEditingState.ShowEditing }
        
        showConfirmationDriver.drive( editPhotoButton.rx_hidden )
            .addDisposableTo(bag)
        
        showConfirmationDriver.drive( editUsernameButton.rx_hidden )
            .addDisposableTo(bag)
        
        showEditingDriver.driveNext { [unowned self] val in
                self.logoutButton.hidden = val
                self.logoutButton.userInteractionEnabled = !self.logoutButton.hidden
            }
            .addDisposableTo(bag)
        
        viewModel.usernameTextBoxViewModel.text
            .asObservable()
            .filter { $0 != nil }.map { $0! }
            .subscribeNext { [unowned self] _ in
                self.dismissViewControllerAnimated(true, completion:nil)
            }
            .addDisposableTo(bag)
        
        viewModel.uploadProgress.asDriver()
            .map { value in
                guard let v = value else { return true }
            
                return !(v > 0 && v < 1)
            }
            .drive(updateProgressBar.rx_hidden)
            .addDisposableTo(bag)
        
        viewModel.uploadProgress.asDriver()
            .driveNext { [unowned self] value in
                guard let percent = value else {
                    return
                }
                
                self.updateProgressBar.setValue(CGFloat(percent * 100.0), animateWithDuration: 0)
            }
            .addDisposableTo(bag)
        
        viewModel.userDriver
            .map{ $0.username }
            .drive(nameLabel.rx_text)
            .addDisposableTo(bag)
        
        viewModel.userDriver
            .map{ $0.pictureURL }
            .filter { $0 != nil }.map { $0! }
            .flatMap { ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(avatarImageView.rx_imageAnimated(kCATransitionFade))
            .addDisposableTo(bag)

        viewModel.userDriver
            .map { "\($0.followersCount ?? 0)" }
            .drive( followersCountLabel.rx_text )
            .addDisposableTo(bag)
        
        viewModel.userDriver
            .map { "\($0.followingCount ?? 0)" }
            .drive( followingCountLabel.rx_text )
            .addDisposableTo(bag)
        
        viewModel.userDriver
            .map { "\($0.points ?? 0)" }
            .drive( pointsCountLabel.rx_text )
            .addDisposableTo(bag)

        viewModel.errorMessage.asObservable()
            .filter { $0 != nil }.map { $0! }
            .subscribeNext { [unowned self] text in
                self.showInfoMessage(withTitle: "Error", text)
            }
            .addDisposableTo(bag)
        
        ///following viewModel
        viewModel.followingViewModel
            .followButtonEnabled
            .drive(followActionsButton.rx_enabled)
            .addDisposableTo(bag)
        
        viewModel.followingViewModel
            .followButtonHidden
            .drive(followActionsButton.rx_hidden)
            .addDisposableTo(bag)
        
        viewModel.followingViewModel
            .followButtonText
            .driveNext { [unowned self] text in
                let attributedText = NSAttributedString(string: text,
                    attributes: [
                        NSForegroundColorAttributeName : UIColor(fromHex: 0xF37C00),
                        NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                        NSFontAttributeName : UIFont.systemFontOfSize(16)
                    ])
                
                self.followActionsButton.setAttributedTitle(attributedText, forState: .Normal)
            }
            .addDisposableTo(bag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        viewModel.logoutAction()
    }
    
    @IBAction func editPhotoAction(sender: AnyObject) {
       viewModel.editPhoto()
    }
    
    @IBAction func editProfileAction(sender: AnyObject) {
        viewModel.editingState.value = .ShowConfirmation
    }
    
    @IBAction func saveProfileAction(sender: AnyObject) {
        viewModel.uploadEdits()
    }
    
    @IBAction func followActionTapped(sender: AnyObject) {
        viewModel.followingViewModel.performAction()
    }
    
    @IBAction func deleteprofileAction(sender: AnyObject) {
        self.showSimpleQuestionMessage(withTitle: "Delete profile", "Your profile, feed posts, reports and other information will be deleted. Are you sure?", {
                self.viewModel.deleteProfile()
            })
    }
}

extension UserProfileViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embed feed" {
            
            let controller = segue.destinationViewController as! FeedCollectionViewController
            controller.viewModel = viewModel.feedViewModel
        }
        else if segue.identifier == "present username textbox" {
            
            let controller = segue.destinationViewController as! TextBoxController
            controller.viewModel = viewModel.usernameTextBoxViewModel
        }
        
    }
    
}