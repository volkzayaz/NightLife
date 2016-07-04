//
//  PhotoDetailsViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift

class MediaDetailsViewController : UIViewController {
    
    var viewModel : MediaDetailsViewModel!
    
    @IBOutlet weak var imageDescriptionLabel: UILabel!
    
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if viewModel == nil { assert(false) /*view model must be initialized before using view controller*/  }
    
        viewModel.mediaDriver
            .map { $0.mediaDescription }
            .drive(imageDescriptionLabel.rx_text)
            .addDisposableTo(bag)
        
        if let postOwnerDirver = User.observableEntityByIdentifier(viewModel.media.postOwnerId)?.asDriver() {
            
            postOwnerDirver.map { $0.pictureURL }
                .filter { $0 != nil }.map { $0! }
                .flatMapLatest { ImageRetreiver.imageForURLWithoutProgress($0) }
                .drive(authorImageView.rx_imageAnimated(kCATransitionFade))
                .addDisposableTo(bag)
            
            postOwnerDirver.map { $0.username }
                .drive(authorNameLabel.rx_text)
                .addDisposableTo(bag)
            
        }
        
        
        clubNameLabel.text = viewModel.club.name
        datelabel.text = viewModel.dateDescription
     
        viewModel.message.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] message in
                self.showInfoMessage(withTitle: "Info", message)
            }
            .addDisposableTo(bag)
        
        viewModel.mediaDriver
            .map { !$0.isLikedByCurrentUser }
            .drive( likeButton.rx_enabled )
            .addDisposableTo(bag)
        
        viewModel.likeProgressIndicator.asDriver()
            .drive(likeButton.rx_hidden)
            .addDisposableTo(bag)
        
        viewModel.likeProgressIndicator.asDriver()
            .drive(likeSpinner.rxex_animating)
            .addDisposableTo(bag)
        
        viewModel.mediaDriver
            .map { "\($0.likesCount)" }
            .drive(likesCountLabel.rx_text)
            .addDisposableTo(bag)
        
        if viewModel.canAlterMedia {
            let editItem = UIBarButtonItem(image: UIImage(named:"edit_icon"), style: .Plain, target: self, action: #selector(MediaDetailsViewController.editTapped))
            
            let deleteItem = UIBarButtonItem(image: UIImage(named:"delete_icon"), style: .Plain, target: self, action: #selector(MediaDetailsViewController.deleteTapped))
            
            navigationItem.rightBarButtonItems = [deleteItem, editItem]
        }
        
        viewModel.editPhotoViewModel.asObservable()
            .filter { $0 != nil }.map { $0! }
            .flatMap { [unowned self] viewModel -> Observable<String?> in
                self.performSegueWithIdentifier("show text box", sender: nil)
                
                return viewModel.text.asObservable()
            }
            .filter { $0 != nil }.map { $0! }
            .subscribeNext { [unowned self] _ in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(bag)
        
        viewModel.shareController.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] controller in
                controller.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
            }
            .addDisposableTo(bag)
        
        viewModel.shareButtonEnabled.asDriver()
            .drive(shareButton.rx_enabled)
            .addDisposableTo(bag)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show text box" {
            let controller =  segue.destinationViewController as! TextBoxController
            
            controller.viewModel = viewModel.editPhotoViewModel.value!
        }
        else if segue.identifier == "embed media player" {
            let controller = segue.destinationViewController as! MediaPlayerViewController
            
            controller.mediaItem.value = viewModel.media
            
            ///FIXME: remove this piece of shi... code
            viewModel.mediaPlayer = controller
        }
        else if segue.identifier == "show profile of other user" {
            
            let controller = segue.destinationViewController as! UserProfileViewController
            
            ///FIXME: move viewModel creation to MediaDetailsViewModel
            controller.viewModel = UserProfileViewModel(userDescriptor: User(id: viewModel.media.postOwnerId))
         }
    }
    
    func editTapped() {
        viewModel.performEditAction()
    }
    
    func deleteTapped() {
        showSimpleQuestionMessage(withTitle: "Confirmation", "Are you sure you want to delete it?", {
            [unowned self] in
            
            self.navigationController?.popViewControllerAnimated(true)
            self.viewModel.performDeleteAction()
            
        })
    }
    
    @IBAction func likeAction(sender: UIButton) {
        
        viewModel.performLikeAction()
        
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        viewModel.shareAction()
    }
    
    static func instantiate() -> MediaDetailsViewController {
        
        let storyboard = UIStoryboard(name: "ClubFeedDetails", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("MediaDetailsViewController") as! MediaDetailsViewController
        
    }
    
    @IBAction func handlePan(sender: AnyObject) {
        
        self.performSegueWithIdentifier("show profile of other user", sender: nil)
        
    }
}

extension MediaDetailsViewController : UIDocumentInteractionControllerDelegate {
    
}