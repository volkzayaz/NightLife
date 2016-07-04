//
//  ReviewPhotoCollectionViewCell.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import MBCircularProgressBar

class ReviewMediaCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var hotImageView: UIImageView!
    
    @IBOutlet weak var playIcon: UIImageView!
    
    private var disposeBag = DisposeBag()
    
    func setMedia( media: MediaItem ) {
        
        playIcon.hidden = media.type != .Video
        
        media.observableEntity()?.asDriver()
            .map { !$0.isHot }
            .drive(hotImageView.rx_hidden)
            .addDisposableTo(disposeBag)
        
        Driver.just("")
            .throttle(0.3)///throttle image loading for quick scrolling case
            .flatMap { _ in
                
                return ImageRetreiver.imageForURL(media.thumbnailURL)
                    .asDriver(onErrorJustReturn: (nil, 1))
                
            }
            .driveNext {[unowned self](maybeImage, progress) in
                
                guard let image = maybeImage else {
                    
                    self.progressBar.hidden = false
                    self.progressBar.setValue(progress * 100, animateWithDuration: 0)
                    
                    return
                }
                
                self.progressBar.hidden = true
                UIView.transitionWithView(self.imageView, duration: 0.4, options: .TransitionCrossDissolve, animations: {
                    self.imageView.image = image
                    }, completion: nil)
                
                
            }
            .addDisposableTo(disposeBag)

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        // because life cicle of every cell ends on prepare for reuse
        disposeBag = DisposeBag()
    }
    
}
