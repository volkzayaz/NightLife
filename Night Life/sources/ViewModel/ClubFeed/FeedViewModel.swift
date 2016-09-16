//
//  FeedViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FeedDataProvider {
    func loadBatch(batch: Batch) -> Observable<[FeedDataItem]>
}

class FeedViewModel {
    
    ///describes next screen transition
    let wireframe: Variable<(String, Any)?> = Variable(nil)
    
    private let disposeBag = DisposeBag()
    
    ///data that is to be displayed (output)
    private (set) var displayData : Variable<[FeedDataItem]> = Variable([])
    var displayDataDriver : Driver<[FeedDataItem]> {
        return displayData.asDriver()
    }
    
    ///these are inputs for FeedViewModel
    ///changing of any of them causes reload for displayData
    ///make sure to set some values or feed will remain empty
    let pageTrigger: Variable<Observable<Void>?> = Variable(nil)
    let dataProvider: Variable<FeedDataProvider?> = Variable(nil)

    ///items that are to be inserted to the head of items sequence
    ///can be altered with insertFeedItemAtBegining: method
    private let addedFeedDataItem : Variable<FeedDataItem?> = Variable(nil)

    private let removedFeedDataItem : Variable<FeedDataItem?> = Variable(nil)
    
    init() {
        
        let trigger = pageTrigger.asObservable().filter { $0 != nil }.map { $0! }
        let dp = dataProvider.asObservable().filter { $0 != nil }.map { $0! }
        
        
        Observable.combineLatest(trigger, dp) { ($0, $1) }
            .flatMapLatest{ [unowned self] (trigger, dp) -> Observable<[FeedDataItem]> in
        
                ///happens when feed will be reloaded (probably worth cleaning in memmory cache here?)
                
                ///retreiving observable from paginatingViewModel
                let paginatedFeed = PaginatingViewModel(dataProvider: FeedDataProviderTrampoline(dp))
                    .load(nextPageTrigger: trigger)

                ///on dataSource changing we must clear stored addedFeedDataItem
                ///not the best solution to do this manually though
                self.addedFeedDataItem.value = nil
                self.removedFeedDataItem.value = nil
                
                ///keeping track of items that might will have been added
                let addedItems = self.addedFeedDataItem.asObservable()
                    .filter { $0 != nil }.map { $0! }
                    .scan([]) { [$1] + $0 }
                    .startWith([])
                
                let removedItems = self.removedFeedDataItem.asObservable()
                    .filter { $0 != nil }.map { $0! }
                    .scan([]) { $0 + [$1] }
                    .startWith([])
                
                ///binding result to display data
                return Observable.combineLatest(addedItems, paginatedFeed, removedItems) { a, p, r -> [FeedDataItem] in
                    (a + p).filter { !r.contains($0) }
                }
                
            }
            .bindTo(displayData)
            .addDisposableTo(disposeBag)
        
        ///media deleting
        wireframe.asDriver()
            .map { $0?.1 as? MediaDetailsViewModel }
            .filter { $0 != nil }.map { $0! }
            .flatMapLatest { $0.postAction.asDriver() }
            .filter { $0 != nil }.map { $0! }
            .map { action in
                switch action {
                case .DeletedMedia(let media):
                    return FeedDataItem.MediaType(media: media)
                }
            }
            .drive(removedFeedDataItem)
            .addDisposableTo(disposeBag)
    }
    
    func presentReportDetails(report: Report) {
        
        guard let identifier = report.clubId,
              let club = Club.entityByIdentifier(identifier) else {
            fatalError("Can't present report without referenced clubId")
        }
        
        Observable.just(club)
            .map{ ("show report details", ReportDetailsViewModel(club: $0, report: report)) }
            .bindTo(wireframe)
            .addDisposableTo(disposeBag)
        
    }
    
    func presentMediaDetails(media: MediaItem) {

        guard let identifier = media.clubId else {
            fatalError("Can't present photo without referenced clubId")
        }
        
        ClubsManager.clubForId(identifier)
            .map{ ("show media details", MediaDetailsViewModel(club: $0, media: media)) }
            .bindTo(wireframe)
            .addDisposableTo(disposeBag)
        
    }
    
}

extension FeedViewModel {
    
    func insertFeedItemAtBegining(item: FeedDataItem) {
        addedFeedDataItem.value = item
    }
    
    private class FeedDataProviderTrampoline : DataProvider {
        typealias DataType = FeedDataItem
        
        private let dataProvider : FeedDataProvider
        init(_ dataProvider: FeedDataProvider) {
            self.dataProvider = dataProvider
        }
        
        private func loadBatch(batch: Batch) -> Observable<[FeedDataProviderTrampoline.DataType]> {
            return dataProvider.loadBatch(batch)
        }
    }
    
    
}