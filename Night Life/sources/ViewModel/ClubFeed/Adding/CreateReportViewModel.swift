//
//  CreateReportViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift

import Alamofire
import RxAlamofire

import ObjectMapper

class CreateReportViewModel {
    
    let composedReport = Variable<Report?>(nil)
    let questionStatusNumber = Variable<Int>(3)
    let errorMessage = Variable<String?>(nil)
    
    var clubName : String { return club.name }
    var clubAdress : String { return club.adress }
    var clubLogoImageURL : String { return club.logoImageURL }
    
    private let club : Club
    
    init(club :Club) {
        self.club = club
        
    }
    
    let disposeBag = DisposeBag()
    
    func submitReport(report: Report) {

        Alamofire.request(FeedDisplayableRouter.CreateReportForClub(report: report, club: club))
            .rx_JSON()
            .subscribe(onNext: { response in
                
                guard let json = response as? [String : AnyObject],
                      let parsedReport = Mapper<Report>().map(json) else {
                    assert(false, "Error recognizing server sturcture");
                    return
                }
                
                parsedReport.postOwnerId = User.currentUser()!.id
                
                self.composedReport.value = parsedReport
                
                }, onError: { (e) -> Void in
                    
                    ///TODO: Hadle error
                    assert(false, "unhadled error on report")
                    
            })
            .addDisposableTo(disposeBag)
        
    }
    
    func moveToNextQuestionPage() {
        
        questionStatusNumber.value+=3
        
    }
    
}