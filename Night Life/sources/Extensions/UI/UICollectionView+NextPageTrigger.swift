//
//  UICollectionView+NextPageTrigger.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/2/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift

extension UICollectionView {
    
    func rxex_cellDisplayed () -> Observable<(collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: NSIndexPath)> {
        
        return self.rx_delegate.observe(#selector(UICollectionViewDelegate.collectionView(_:willDisplayCell:forItemAtIndexPath:)))
            .flatMap { args -> Observable<(t: UICollectionView, c: UICollectionViewCell, i: NSIndexPath)> in
                let c = args[0] as! UICollectionView
                let v = args[1] as! UICollectionViewCell
                let i = args[2] as! NSIndexPath
                
                let element = (c,v,i)
                
                return Observable.just( element )
        }
        
    }
}