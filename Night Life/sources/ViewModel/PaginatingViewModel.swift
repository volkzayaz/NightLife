//
//  PaginatingViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift

struct Batch {
    let offset:Int
    let limit:Int
}

protocol DataProvider {
    
    associatedtype DataType
    
    func loadBatch(batch: Batch) -> Observable<[DataType]>
}

class PaginatingViewModel<S: DataProvider> {
    
    private let dataProvider: S
    init(dataProvider: S) {
        self.dataProvider = dataProvider
    }
    
    func load
        (nextPageTrigger nextPageTrigger: Observable<Void>)
        -> Observable<[S.DataType]> {
        return recursivelyLoad(  [],
                    dataProvider: dataProvider,
                 nextPageTrigger: nextPageTrigger)
                .startWith([])
    }
    
}

extension PaginatingViewModel {
    
    private func recursivelyLoad
        (loadedSoFar: [S.DataType],
        dataProvider: S,
        nextPageTrigger: Observable<Void>) -> Observable<[S.DataType]> {
        
        return dataProvider.loadBatch(Batch(offset: loadedSoFar.count, limit: 10))
            .flatMap { loadedNew -> Observable<[S.DataType]> in
                
                guard loadedNew.count > 0 else {
                    ///loaded everything we could
                    return Observable.empty()
                }
                
                var totalResults = loadedSoFar
                totalResults.appendContentsOf(loadedNew)
                
                return [
                    // return loaded immediately
                    Observable.just(totalResults),
                    // wait until next page can be loaded
                    Observable.never().takeUntil(nextPageTrigger),
                    // load next page
                    self.recursivelyLoad(totalResults, dataProvider: dataProvider, nextPageTrigger: nextPageTrigger)
                    ].concat()
                
        }
    }

}