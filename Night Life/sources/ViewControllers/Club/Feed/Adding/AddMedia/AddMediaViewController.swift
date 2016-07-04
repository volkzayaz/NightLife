 //
//  AddPhotoViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/29/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift

import RxCocoa

import MBCircularProgressBar
import MobileCoreServices

class AddMediaViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
   
    var viewModel: AddMediaViewModel!
    private let disposeBag = DisposeBag()
    
    private weak var mediaPlayerController: MediaPlayerViewController!
    
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    @IBOutlet weak var descriptionTextField: UITextField! {
        didSet {
            descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Add a caption", attributes: [NSForegroundColorAttributeName:UIColor(red: 117, green: 117, blue: 117), NSFontAttributeName: UIFont(name: "Raleway", size: 12)!])
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    private let gradientLayer: CALayer = UIConfiguration.gradientLayer(    UIColor(fromHex: 0x171717),
                                                                       to: UIColor(fromHex: 0x343434))
    
    private var imagePicker: UIImagePickerController = {
        
        let picker = UIImagePickerController()
        
        picker.sourceType = .Camera
        picker.allowsEditing = true
        picker.videoMaximumDuration = AppConfiguration.maximumRecordedVideoDuration
        
        return picker
    }()
    
    override func loadView() {
        super.loadView()
        
        if viewModel == nil { fatalError("viewModel must be initialized prior to using AddMediaViewController") }
        
        imagePicker.mediaTypes = viewModel.mediaType == .Photo ? [kUTTypeImage as String] : [kUTTypeMovie as String]
        imagePicker.delegate = self
        
        self.title = "Add Media"
        
        scrollView.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // comment here to run the app on simulator without crash
        self.presentViewController(imagePicker, animated: false, completion: nil)
        
        //// keyboard show hide
        NSNotificationCenter.defaultCenter()
                .rx_notification(UIKeyboardWillShowNotification)
                .subscribeNext { [unowned self] notification in
        
                    let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
                    
                    var offset = self.scrollView.contentOffset
                    
                    let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
                    
                    if (self.scrollView.frame.size.height - (self.descriptionTextField.frame.origin.y + self.descriptionTextField.frame.size.height) + self.scrollView.contentOffset.y)  < keyboardSize.origin.y
                    {
                        offset.y += keyboardSize.height
                 
                        UIView.animateWithDuration(duration) { self.scrollView.contentOffset = offset }
                    }
                }
                .addDisposableTo(disposeBag)
        
        NSNotificationCenter.defaultCenter()
            .rx_notification(UIKeyboardWillHideNotification)
            .subscribeNext { [unowned self] notification in
                
                let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
                
                var offset = self.scrollView.contentOffset
                offset.y = 0.0
                
                UIView.animateWithDuration(duration) { self.scrollView.contentOffset = offset }
            }
            .addDisposableTo(disposeBag)
//
        ////upload progress
        viewModel.uploadProgress.asDriver()
            .driveNext { [unowned self] value in
                guard let percent = value else {
                    return
                }
                
                self.progressView.hidden = false
                self.progressView.setValue(CGFloat(percent * 100.0), animateWithDuration: 0)
            }
            .addDisposableTo(disposeBag)
        
        
        ///upload button
        let uploadBarButtonItem = UIBarButtonItem(image: UIImage(named: "check"), style: .Plain, target: self, action: #selector(mock))
        uploadBarButtonItem.rx_tap
            .flatMap { [weak t = self.descriptionTextField] _ -> Driver<String> in
                t!.resignFirstResponder()
                return t!.rx_text.asDriver()
            }
            .subscribeNext { [unowned self] description in
                self.descriptionTextField.hidden = true
                
                self.viewModel.uploadSelectedMedia(description)
            }
            .addDisposableTo(disposeBag)
        self.navigationItem.rightBarButtonItem = uploadBarButtonItem
        
        ///selection media binding
        viewModel.selectedImage.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] image in
                self.mediaPlayerController.image.value = image
            }
            .addDisposableTo(disposeBag)
        
        viewModel.selectedVideoURL.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] tuple in
                self.mediaPlayerController.playableContentURL.value = tuple.0
            }
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = self.scrollView.bounds
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let url = info[UIImagePickerControllerMediaURL] as? NSURL {
            viewModel.addedVideo(url)
        }
        else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            viewModel.addedPhoto(image)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(false, completion: nil)
        self.progressView.hidden = true
        self.viewModel.cancelMediaAdding()
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func mock() {}
}

extension AddMediaViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embed media player" {
            mediaPlayerController = segue.destinationViewController as! MediaPlayerViewController
        }
    }
    
}