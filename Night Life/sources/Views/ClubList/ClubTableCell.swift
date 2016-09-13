//
//  ClubTableCell.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/26/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire

class ClubTableCell : UITableViewCell {
    
    @IBOutlet weak var travelButton: UIButton!
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var adresLabel: UILabel!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var checkinCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel! {
        didSet {
            distanceLabel.layer.borderWidth  = 1
            distanceLabel.layer.borderColor = UIColor.whiteColor().CGColor
            distanceLabel.layer.cornerRadius = 3
        }
    }
    
    @IBOutlet weak var lastCheckinUsersView: CircularIconsGroupView!
    
    @IBOutlet weak var gradientContainer: GradientView!
    
    private var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        lastCheckinUsersView.addIconURLs([])
    }
    
    func setClub(club: Club) {
        
        guard let clubVariable = club.observableEntity() else {
            print("Can't set club info. No club stored for id \(club.identifier)")
            return
        }
        
        let clubDriver = clubVariable.asDriver()
        
        clubDriver.map { $0.name }
            .drive(clubNameLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        clubDriver.map { $0.adress }
            .drive(adresLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        ImageRetreiver.imageForURLWithoutProgress(clubVariable.value.coverPhotoURL)
            .drive(coverPhotoImageView.rx_imageAnimated(kCATransitionFade))
            .addDisposableTo(disposeBag)

        clubDriver
            .flatMap { club in
                club.lastCheckedInUsers /// all lastCheckedInUsers
                    .flatMap { ///filtering out users taht are not in storage
                        $0.observableEntity()?.asDriver() /// getting observable user from storage
                    }
                    .combineLatest { actualUsers in ///mapping true users to their picture URLs
                        actualUsers.map { $0.pictureURL! }
                }
            }
            .driveNext { [unowned self] icons in
                self.lastCheckinUsersView.addIconURLs(icons)
            }
            .addDisposableTo(disposeBag)
        
        clubDriver
            .map{ String($0.checkinsCount) }
            .drive( checkinCountLabel.rx_text )
            .addDisposableTo(disposeBag)
        
        clubDriver
            .map{ String($0.likesCount) }
            .drive( likeCountLabel.rx_text )
            .addDisposableTo(disposeBag)
        
        clubDriver
            .map{ $0.isLikedByCurrentUser ? "like_on" : "like_off" }
            .distinctUntilChanged()
            .map{ name -> UIImage in UIImage(named: name)! }
            .driveNext { [unowned self] (image: UIImage) in
                
                let crossFade = CABasicAnimation(keyPath: "contents")
                crossFade.duration = 0.2
                crossFade.fromValue = self.likeButton.imageView?.image?.CGImage
                crossFade.toValue = image.CGImage
                crossFade.removedOnCompletion = false
                crossFade.fillMode = kCAFillModeForwards;
                self.likeButton?.imageView?.layer.addAnimation(crossFade, forKey:"animateContents")
                
                //Make sure to add Image normally after so when the animation
                //is done it is set to the new Image
                self.likeButton.setImage(image, forState: .Normal)
                
            }
            .addDisposableTo(disposeBag)

        likeButton.rx_tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .flatMapLatest{ _ -> Observable<AnyObject> in
                let clubValue = clubVariable.value
                
                let rout = clubValue.isLikedByCurrentUser ?
                PlacesRouter.UnLike(club: clubValue) :
                PlacesRouter.Like(club: clubValue)
                
                return Alamofire.request(rout).rx_responseJSON().map{ $0.1 }
            }
            .subscribe(onNext: { _ in
                
                    var clubValue = clubVariable.value
                    clubValue.switchLikeStatus()
                    clubValue.saveEntity()
                    
                }, onError: { e in
                    print("Error switching like status")
                })
            .addDisposableTo(disposeBag)
        
        ///fake locationdffsdf
        LocationManager.instance.fakeLocation.asDriver()
            .driveNext { [unowned self] maybeLocation in
                guard let location = maybeLocation where
                    location.coordinate.longitude == clubVariable.value.location.coordinate.longitude
                    else {
                        
                        self.travelButton.enabled = true
                        self.travelButton.setTitle("Travel to this this club", forState: .Normal)
                        
                        return
                }
                self.travelButton.enabled = false
                self.travelButton.setTitle("You're in nearby this club", forState: .Normal)
                
            }
        .addDisposableTo(disposeBag)
        
        travelButton.rx_tap.subscribeNext{ _ in
            LocationManager.instance.fakeLocation.value = clubVariable.value.location
        }
        .addDisposableTo(disposeBag)
        
#if ADHOC || DEBUG
        travelButton.hidden = false
#else
        travelButton.hidden = true
#endif
        
        ///location label
        Observable.combineLatest(clubDriver.asObservable(),
                                 LocationManager.instance
                                    .lastRecordedLocationObservable) { club, location in
                                        location.distanceFromLocation(club.location).metersToMiles
            }
            .map { String(format: "%.2f miles", $0) }
            .bindTo(distanceLabel.rx_text)
            .addDisposableTo(disposeBag)
    }
    
}
