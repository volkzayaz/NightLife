//
//  PhotoDetailsViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire
import ObjectMapper

import MobileCoreServices

enum PostMediaDetailsAction {
    
    case DeletedMedia(media: MediaItem)
    
}

struct MediaDetailsViewModel {
    
    let club: Club
    let media: MediaItem
    let message: Variable<String?> = Variable(nil)
    let bag = DisposeBag()
    let likeProgressIndicator = ViewIndicator()
    
    let editPhotoViewModel: Variable<TextBoxViewModel?> = Variable(nil)
    
    let shareController: Variable<UIDocumentInteractionController?> = Variable(nil)
    let shareButtonEnabled: Variable<Bool> = Variable(false)
    
    let postAction = Variable<PostMediaDetailsAction?>(nil)
    
    var mediaDriver: Driver<MediaItem> {
        guard let m = media.observableEntity() else {
            fatalError("Can't present details of media that has not been stored in memmory storage")
        }
        
        return m.asDriver()
    }
    
    ///FIXME: reimplement to MediaPlayer ViewModel. Observe data on it's viewModel and get rid of ViewController reference here
    weak var mediaPlayer: MediaPlayerViewController? {
        didSet {
            guard let m = mediaPlayer else { return }
            
            [m.image.asObservable().map ({ $0 != nil }),
            m.playableContentURL.asObservable().map ({ $0 != nil })].toObservable()
            .merge()
            .bindTo(shareButtonEnabled)
            .addDisposableTo(bag)
        }
    }
    
    var canAlterMedia: Bool {
        get {
            return media.postOwnerId == User.currentUser()!.id
        }
    }
    
    init(club: Club, media: MediaItem) {
        self.club = club
        self.media = media
        
        let a =
        editPhotoViewModel.asObservable()
            .filter { $0 != nil }.map { $0! }
            .flatMapLatest { viewModel -> Observable<String?> in
                return viewModel.text.asObservable()
            }
            .filter { $0 != nil }.map { $0! }
        
        
        Observable.combineLatest(a, Observable.just(media).take(1)) { ($0, $1) }
            .subscribeNext { args in
                Alamofire.upload(FeedDisplayableRouter.UpdateMediaDescription,
                    multipartFormData: { formData in
                        
                        formData.appendBodyPart(data: "\(args.1.id)".dataUsingEncoding(NSUTF8StringEncoding)!,
                            name: "report_pk")
                        formData.appendBodyPart(data: args.0.dataUsingEncoding(NSUTF8StringEncoding)!, name: "description")
                        
                    }, encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            
                            upload.rx_responseJSON()
                                .map { _ in
                                    
                                    self.media.mediaDescription = args.0
                                    self.media.saveEntity()
                                    
                                    return "Description updated"
                                }
                                .bindTo(self.message)
                                .addDisposableTo(self.bag)
                            
                        case .Failure(let encodingError):
                            
                            assert(false, "\(encodingError)")
                            
                        }
                })
                
            }
            .addDisposableTo(bag)
        
    }
    
    var mediaURL : String {
        return media.mediaURL
    }
    
    var dateDescription: String {
        return UIConfiguration.stringFromDate(media.createdDate!)
    }
    
    var user: String {
        return UIConfiguration.stringFromDate(media.createdDate!)
    }
    
    func performLikeAction() {
        
        Alamofire.request(FeedDisplayableRouter.LikeMedia(media: media))
            .rx_responseJSON()
            .trackView(likeProgressIndicator)
            .map { _ -> String in
                
                self.media.setLikeStatusOn()
                self.media.saveEntity()
                
                return "Succesfully Liked photo"
            }
            .catchError{ (er: ErrorType) -> Observable<String?> in
                
                return Observable.just("Internal server error. Give this info to the devs it might be helpful: " + (er as NSError).description)
            }
            .bindTo(message)
            .addDisposableTo(bag)
        
    }
    
    func performEditAction() {
        editPhotoViewModel.value = TextBoxViewModel(displayText: media.mediaDescription)
    }
    
    func performDeleteAction() {
        
        Alamofire.request(FeedDisplayableRouter.DeleteMedia(media: media))
            .rx_responseJSON()
            .map { response -> PostMediaDetailsAction in
                
                ImageRetreiver.flushImageForKey(self.media.thumbnailURL)
                ImageRetreiver.flushImageForKey(self.media.mediaURL)
                self.media.removeFromStorage()
                
                return .DeletedMedia(media: self.media)
            }
            .bindTo(postAction)
            .addDisposableTo(bag)
        
    }
    
    func shareAction() {
        
        guard let type = media.type where type == .Photo || type == .Video,
              let player = mediaPlayer else {
            fatalError("Can't share media other than Photo or Video")
        }

        let exportPath = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: [.UserDomainMask]).first!.URLByAppendingPathComponent("temp")
        
        var uti: String? = type == .Photo ? kUTTypeImage as String : kUTTypeQuickTimeMovie as String
        
        if type == .Photo {
            
            guard let image = player.image.value else {
                fatalError("Can't share without image loaded on mediaPlayer")
            }
            
            ///writing to public folder
            UIImageJPEGRepresentation(image, 1)!.writeToURL(exportPath, atomically: true)
            
            uti = kUTTypeJPEG as String
        }
        else if type == .Video {
            guard let videoURL = player.playableContentURL.value else {
                fatalError("Can't share without video stored on disk")
            }
            
            NSData(contentsOfURL: videoURL)!.writeToURL(exportPath, atomically: true)
            
            uti = kUTTypeMPEG4 as String
        }
        
        let controller = UIDocumentInteractionController(URL: exportPath)
        controller.UTI = uti
        
        shareController.value = controller
    }
    
}