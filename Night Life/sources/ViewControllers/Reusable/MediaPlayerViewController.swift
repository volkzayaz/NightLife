//
//  MediaPlayerViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/8/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation
import Alamofire
import RxCocoa

class MediaPlayerViewController : UIViewController {
    
    deinit {
        downloadTask?.cancel()
    }
    
    private var downloadTask: Alamofire.Request? = nil
    
    let mediaItem: Variable<MediaItem?> = Variable(nil)
    let imageURL: Variable<NSURL?> = Variable(nil)
    let image: Variable<UIImage?> = Variable(nil)
    let playableContentURL: Variable<NSURL?> = Variable(nil)
    
    private var player: AVPlayer = AVPlayer()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playbackIcon: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let bag = DisposeBag()
    
    @IBAction func invertPlaybackRate(sender: AnyObject) {
        player.rate == 0 ? play() : pause()
    }
    
    private func play() {
        player.play()
        playbackIcon.hidden = true
    }
    
    private func pause() {
        player.pause()
        playbackIcon.hidden = false
    }
    
    private var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        self.view.layer.insertSublayer(playerLayer!, atIndex: 0)
        
        NSNotificationCenter.defaultCenter().rx_notification(AVPlayerItemDidPlayToEndTimeNotification)
            .subscribeNext { [weak p = player] _ in
                p?.pause()
                p?.seekToTime(kCMTimeZero)
                p?.play()
            }
            .addDisposableTo(bag)
        
        mediaItem.asDriver()
            .filter { $0 != nil }.map { $0! }
            .filter { [unowned self] media in
                if media.type == .Photo {
                    self.imageURL.value = NSURL(string: media.mediaURL)!
                    return false
                }
                
                return media.type == .Video
            }
            .driveNext { [unowned self] media in
                
                     let urlRequest = NSURLRequest(URL: NSURL(string: media.mediaURL)!)
                        
                        var url :NSURL? = nil
                        
                        self.activityIndicator?.hidden = false
                
                        self.downloadTask =
                            Alamofire.Manager.sharedInstance
                                .download(urlRequest) { (temporaryURL, response) in
                                    
                                    url = Alamofire.Request.suggestedDownloadDestination() (temporaryURL , response)
                                    
                                    let _ = try? NSFileManager.defaultManager().removeItemAtURL(url!)
                                    
                                    return url!
                        }
                        
                        self.downloadTask?
                            .response { [weak self] (_,_,_,_) in
                                self?.activityIndicator?.hidden = true
                                
                                self?.playableContentURL.value = url
                        }
            }
            .addDisposableTo(bag)
        
        imageURL.asObservable()
            .flatMap { maybeUrl -> Observable<UIImage?> in
                guard let url = maybeUrl else { return Observable.just(nil) }
                
                return ImageRetreiver.imageForURLWithoutProgress(url.absoluteString).asObservable()
            }
            .bindTo(image)
            .addDisposableTo(bag)
        
        image.asDriver()
            .filter { $0 != nil }.map { $0! }
            .drive(imageView.rx_imageAnimated(kCATransitionFade))
            .addDisposableTo(bag)
        
        playableContentURL.asObservable()
            .map { ($0 == nil, $0 != nil ? AVPlayerItem(URL: $0!) : nil) }
            .subscribeNext { [unowned self] (value: (Bool, AVPlayerItem?) ) in
                self.playbackIcon.hidden = value.0
                self.player.replaceCurrentItemWithPlayerItem(value.1)
            }
            .addDisposableTo(bag)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer?.frame = self.view.bounds
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        pause()
    }
    
}
