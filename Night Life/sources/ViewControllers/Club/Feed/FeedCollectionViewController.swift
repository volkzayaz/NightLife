//
//  FeedCollectionViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

protocol FeedHeaderDataSource : class {
    
    var headerHeight: CGFloat { get }
    
    func populateHeaderView(view: UICollectionReusableView)
}

class FeedCollectionViewController : UICollectionViewController {
    
    var viewModel : FeedViewModel!
    weak var headerDataSource: FeedHeaderDataSource?
    
    private let dataSource = RxCollectionViewSectionedAnimatedDataSource<FeedSection>()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (viewModel == nil) { fatalError("viewModel must be initialized prior to using FeedCollectionViewController") }
        
        viewModel.wireframe.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] tuple in
                self.performSegueWithIdentifier(tuple.0, sender: nil)
             }
            .addDisposableTo(disposeBag)

        
        setUpFeed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let flowLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = collectionView!.frame.size.width / 3 - 1
        
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 2
        
        flowLayout.headerReferenceSize = CGSize(width: collectionView!.frame.size.width,
                                                height: headerDataSource?.headerHeight ?? 0)
        
    }
    
    private func setUpFeed() {
        
        collectionView?.delegate = nil
        collectionView?.dataSource = nil
        
        ///pagination trigger
        viewModel.pageTrigger.value = collectionView!
            .rx_contentOffset
            .map{ [weak c = self.collectionView] offset -> (CGFloat, UICollectionView?) in
                return (offset.y, c)
            }
            .flatMapLatest { args -> Observable<Void> in
                
                guard let collectionView = args.1 else { return Observable.empty() }
                
                let offset = args.0
                let shouldTriger = offset + collectionView.frame.size.height + 70 > collectionView.collectionViewLayout.collectionViewContentSize().height
                return shouldTriger ? Observable.just() : Observable.empty()
        }
        
        ///cell factory
        dataSource.cellFactory = { (_, cv, ip, item) in
            
            switch item {
            case .MediaType(let mediaContext):
                let cell = cv.dequeueReusableCellWithReuseIdentifier("media cell", forIndexPath: ip) as! ReviewMediaCollectionCell
                
                cell.setMedia(mediaContext)
                
                return cell
                
            case .ReportType(let report):
                let cell = cv.dequeueReusableCellWithReuseIdentifier("report cell", forIndexPath: ip) as! ReviewReportCollectionCell
                
                cell.setReport(report)
                
                return cell
            }
            
        }
        
        dataSource.supplementaryViewFactory = { [unowned self] (_, cv, kind, ip) in
            let a = cv.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "feed header", forIndexPath: ip)
            self.headerDataSource?.populateHeaderView(a)
            return a
        }
        
        ///data binding to collection view
        //let data: Observable<[FeedSection]> =
        viewModel.displayDataDriver
            .map { items -> [FeedSection] in
                return [FeedSection(items: items)]
            }
            .drive(collectionView!.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        ///collection view event reacting
        collectionView!.rx_modelSelected(FeedDataItem.self)
            .asDriver()
            .driveNext { [unowned self] in
                
                switch $0 {
                    
                case .MediaType(let media):
                    self.viewModel.presentMediaDetails(media)
                    
                case .ReportType(let report):
                    self.viewModel.presentReportDetails(report)
                }
                
            }
            .addDisposableTo(disposeBag)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show report details"
        {
            
            let controller = segue.destinationViewController as! ReportDetailsViewController
            controller.viewModel = self.viewModel.wireframe.value!.1 as! ReportDetailsViewModel
            
        }
        else if segue.identifier == "show media details"
        {
            
            let controller = segue.destinationViewController as! MediaDetailsViewController
            controller.viewModel = self.viewModel.wireframe.value!.1 as! MediaDetailsViewModel
            
        }
    }
    
}

struct FeedSection : AnimatableSectionModelType  {
    
    typealias Item = FeedDataItem
    typealias Identity = String
    
    var items: [Item] {
        return feedItems
    }
    
    var identity : String {
        return ""
    }
    
    init(original: FeedSection, items: [Item]) {
        self = original
        self.feedItems = items
    }
    
    var feedItems: [FeedDataItem]
    
    init(items: [FeedDataItem]) {
        self.feedItems = items
    }
    
}