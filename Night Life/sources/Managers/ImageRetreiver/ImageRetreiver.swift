//
//  ImageRetreiver.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/1/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import RxCocoa

import Alamofire
import Kingfisher

typealias ImageRetreiveResult = (image: UIImage?, progress: CGFloat)

enum ImageRetreiverError: ErrorType {
    
    case CorruptedDataDownloaded
    
    
}

/**
 *  @discussion - Utility for retreiving image by given URL in Rx-way
 *  downloaded image is cached and used on next calls to save up on Internet traffic
*/
struct ImageRetreiver {

    private static var imageCache: ImageCache {
        let cache = KingfisherManager.sharedManager.cache
        
        cache.maxDiskCacheSize = 50 * 1024 * 1024
        
        return cache
    }
    
    static func imageForURLWithoutProgress(url: String) -> Driver<UIImage?> {
        
        return self.imageForURL(url)
            .map { $0.image }
        
    }
    
    static func imageForURL(url: String) -> Driver<ImageRetreiveResult> {
        
        return imageCache
            .rxex_retreiveImageForKey(url)
            .flatMap{ maybeImage -> Observable<ImageRetreiveResult> in
                
                if let image = maybeImage {
                    return Observable.just((image,1))
                }

                return Observable.create { observer in
                    
                    let imageLoadRequest = Alamofire.request(.GET, url)
                        .progress{ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                            let value = totalBytesExpectedToWrite > 0 ?
                            CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite) : 0
                            
                            observer.onNext((nil, value))
                        }
                        .responseData{ result in
                            if let error = result.result.error {
                                observer.onError(error)
                                return
                            }
                            
                            guard let imageData = result.result.value,
                                  let image = UIImage(data: imageData) else {
                                
                                observer.onNext((nil, 0))
                                return
                            }
                            
                            imageCache.storeImage(image, forKey: url, toDisk: true, completionHandler: nil)
                            
                            observer.onNext((image, 1))
                        }
                    
                    return AnonymousDisposable {
                        imageLoadRequest.cancel()
                    }
                }
                .retry(3)
                
            }
            .asDriver(onErrorJustReturn: (nil, 0))
        
    }
    
    static func registerImage(image: UIImage, forKey key: String) {
        
        imageCache.storeImage(image, forKey: key, toDisk: true, completionHandler: nil)
        
    }
    
    static func cachedImageForKey(key: String) -> UIImage? {
        
        return imageCache.retrieveImageInDiskCacheForKey(key)
        
    }
    
    static func flushImageForKey(key: String) {
        
        imageCache.removeImageForKey(key)
        
    }
    
    static func flushCache() {
        imageCache.clearMemoryCache()
    }
}

extension ImageCache {
    
    func rxex_retreiveImageForKey(key: String) -> Observable<UIImage?> {
        
        return Observable.create { [unowned self] observer in
            
            self.retrieveImageForKey(key, options: nil) { (maybeImage: Image?, _) in
                
                if let image = maybeImage {
                    observer.onNext(image)
                }
                else {
                    observer.onNext(nil)
                }
                
                observer.onCompleted()
                
            }
            
            return NopDisposable.instance
        }

        
    }
    
}
