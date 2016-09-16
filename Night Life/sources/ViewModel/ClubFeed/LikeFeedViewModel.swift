//
//  File.swift
//  GlobBar
//
//  Created by Andrew Seregin on 9/16/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LikeFeedViewModel {
    
    ///describes next screen transition
    let wireframe: Variable<(String, Any)?> = Variable(nil)
    
    private let disposeBag = DisposeBag()
    
    ///data that is to be displayed (output)
    private var displayData : Variable<[FeedDataItem]> = Variable([])
    var displayDataDriver : Driver<[FeedDataItem]> {
        return displayData.asDriver()
    }
    
    init() {
        
        LikeManager.arrayOfLikes.asObservable()
            .map{ (reports : [Report]) -> [FeedDataItem] in
                return reports.map{ (report : Report) -> FeedDataItem in
                    return .ReportType(report: report)
                }
            }.bindTo(displayData)
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
}
