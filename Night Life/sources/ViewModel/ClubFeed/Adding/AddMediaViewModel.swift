//
//  AddMediaViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/29/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import RxAlamofire
import ObjectMapper

import AVFoundation

enum PostAddMediaActions {
    
    case NoAction
    case MediaAdded(media: MediaItem)
    
}

struct AddMediaViewModel {

    let postAction = Variable<PostAddMediaActions?>(nil)
    let uploadProgress = Variable<Float?>(nil)
    
    let selectedImage: Variable<UIImage?> = Variable(nil)
    let selectedVideoURL: Variable<(NSURL, UIImage)?> = Variable(nil)
    
    let bag = DisposeBag()
    
    private let club: Club
    let mediaType: MediaItemType
    
    
    init(club: Club, type: MediaItemType) {
        self.club = club
        self.mediaType = type
    }
    
    func uploadSelectedMedia(description: String) {
        
        if let image = selectedImage.value {
            uploadPhoto(image, description: description)
        }
        else if let videoTuple = selectedVideoURL.value {
            uploadVideo(videoTuple.0, thumbnail: videoTuple.1, description: description)
        }
        
    }
    
    
    func addedPhoto(image: UIImage) {
        selectedImage.value = image
    }
    
    func addedVideo(url: NSURL) {
        
        ///probably fire spinner while we prepare thumbnail
        ThumbnailGenerator.thumbnailObservable(url)
            .subscribeNext { image in
                self.selectedVideoURL.value = (url, image)
        }
        .addDisposableTo(bag)
        
    }
    
    func cancelMediaAdding() {
        
        postAction.value = .NoAction
        
    }
    
}

extension AddMediaViewModel {
    
    private func uploadPhoto(image: UIImage, description: String) {
        
        let fixedImage = image.fixOrientation()
        
        mediaUpload(.UploadPhoto, formSerializer: { formData in
            
            formData.appendBodyPart(data: UIImageJPEGRepresentation(fixedImage, 0.6)!,
                name: "file",
                fileName: "image.jpg",
                mimeType: "image/jpg")
            
            formData.appendBodyPart(data: "\(self.club.id)".dataUsingEncoding(NSUTF8StringEncoding)!,
                name: "place_pk")
            formData.appendBodyPart(data: description.dataUsingEncoding(NSUTF8StringEncoding)!, name: "description")
            
        }) { mediaItem in
            
            ImageRetreiver.registerImage(fixedImage, forKey: mediaItem.mediaURL)
            ImageRetreiver.registerImage(fixedImage, forKey: mediaItem.thumbnailURL)
            
            self.postAction.value = .MediaAdded(media: mediaItem)
        }
        
    }
    
    private func uploadVideo(fileURL: NSURL, thumbnail: UIImage, description: String) {
        
        let fixedThumbnail = thumbnail.fixOrientation()
        
        mediaUpload(.UploadVideo, formSerializer: { (formData: MultipartFormData) in
            
            formData.appendBodyPart(fileURL: fileURL,
                name: "file",
                fileName: "video.mov",
                mimeType: "video/quicktime")
            
            formData.appendBodyPart(data: UIImageJPEGRepresentation(fixedThumbnail, 0.6)!,
                name: "thumbnail",
                fileName: "video_thumbnail.jpg",
                mimeType: "image/jpg")
            
            formData.appendBodyPart(data: "\(self.club.id)".dataUsingEncoding(NSUTF8StringEncoding)!,
                name: "place_pk")
            formData.appendBodyPart(data: description.dataUsingEncoding(NSUTF8StringEncoding)!, name: "description")
            
        }) { mediaItem in
            
            //ImageRetreiver.registerImage(image, forKey: mediaItem.mediaURL)
            
            self.postAction.value = .MediaAdded(media: mediaItem)
        }
        
    }
    
    private func mediaUpload( rout: FeedDisplayableRouter,
                              formSerializer: MultipartFormData -> (),
                              completitionHandler: MediaItem -> () ) {
        
        Alamofire.upload(rout,
                         multipartFormData: formSerializer,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .Success(let upload, _, _):
                                
                                upload.rx_progress()
                                    .map { $0.floatValue() }
                                    .bindTo(self.uploadProgress)
                                    .addDisposableTo(self.bag)
                                
                                
                                upload.rx_responseJSON()
                                    .subscribe(onNext: { photoJSON in
                                        
                                        guard let json = photoJSON.1 as? [String : AnyObject] else {
                                            assert(false, "Error recognizing server sturcture");
                                            return
                                        }
                                        
                                        guard let parsedMedia = Mapper<MediaItem>().map(json) else {
                                            assert(false, "unhadled error on parsing responce")
                                            return
                                        }
                                        parsedMedia.postOwnerId = User.currentUser()!.id
                                        
                                        parsedMedia.saveEntity()
                                        completitionHandler(parsedMedia)
                                        
                                        }, onError: { (e) -> Void in
                                            
                                            ///TODO: Hadle error
                                            assert(false, "unhadled error on add photo")
                                            
                                    })
                                    .addDisposableTo(self.bag)
                                
                            case .Failure(let encodingError):
                                
                                assert(false, "\(encodingError)")
                                
                            }
        })

    }
    
}