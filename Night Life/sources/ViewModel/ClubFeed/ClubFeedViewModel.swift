//
//  ClubFeedViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/25/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire
import ObjectMapper

typealias MessageTuple = (title: String, message: String)
typealias SimpleAction = () -> Void

struct ClubFeedViewModel {
    
    let infoMessage: Variable<MessageTuple?> = Variable(nil)
    let addPhotoAction: Variable<(MessageTuple, yesHandler: SimpleAction, noHandler: SimpleAction)?> = Variable(nil)
    let activeViewModel: Variable<Any?> = Variable(nil)
    
    let disposeBag = DisposeBag()
    
    let club: Club

    let feedViewModel: FeedViewModel = FeedViewModel()
    
    init(club: Club, startFromCheckin: Bool = false) {
        
        self.club = club
        
        if club.observableEntity() == nil {
            
            ///we're gonna refreh club soon
            club.saveEntity()
        }
        
        ///we don't have enough info to fully present club description yet
        if Club.entityByIdentifier(club.id)?.clubDescriptors.ageGroup == nil {
            ClubsManager.clubForId(club.id, forceRefresh: true)
                .subscribeNext {_ in }
                .addDisposableTo(disposeBag)
        }
        
        if startFromCheckin {
            presentCheckinScreen(nil)
        }
    }
    
    func filterAtIndexSelected(index: Int) {
        
        let dp = ClubFeedDataProvider(club: club,
                                    filter: FeedFilter(rawValue: index)!)
        
        feedViewModel.dataProvider.value = dp
        
    }
    
}

extension ClubFeedViewModel {
    
    func addMedia(type: MediaItemType) {
        
        if canAddCheckinDependentModel(type == .Photo ? .AddPhoto : .AddVideo) {
            let addMediaViewModel = AddMediaViewModel(club: club, type: type)
            
            addMediaViewModel.postAction.asObservable()
                .filter { $0 != nil }
                .map { $0! }
                .subscribeNext { action in
                    switch action {
                        
                    case .NoAction:
                        self.activeViewModel.value = nil
                        
                    case .MediaAdded(let media):
                        self.activeViewModel.value = nil
                        
                        ///adding created report to feed
                        self.feedViewModel.insertFeedItemAtBegining(.MediaType(media: media))
                        
                        ///showing success message 
                        self.infoMessage.value = ("Success", "Media is uploaded!")
                        
                    }
                    
                }
                .addDisposableTo(disposeBag)
            
            activeViewModel.value = addMediaViewModel
        }
        
    }
    
    func addReport() {
        
        if canAddCheckinDependentModel(PostCheckinAction.AddReport) {
            let reportViewModel = CreateReportViewModel(club: club)
            
            reportViewModel.composedReport.asObservable()
                .filter{ $0 != nil }
                .map { $0! }
                .subscribeNext { composedReport in
                    self.activeViewModel.value = nil
                    
                    ///adding created report to feed
                    self.feedViewModel.insertFeedItemAtBegining(.ReportType(report: composedReport))
                    
                    ///presenting success message
                    let message : MessageTuple = ("Success", "Report created and submitted, Good job! Would you like to create a photo?")
                    self.addPhotoAction.value = (message, {
                        self.addMedia(.Photo)
                    },
                    {
                        self.feedViewModel.presentReportDetails(composedReport)
                    })
                }
                .addDisposableTo(disposeBag)
            
            activeViewModel.value = reportViewModel
        }
        
    }
    
    private func canAddCheckinDependentModel(predefinedAction: PostCheckinAction?) -> Bool {

        guard let userLocation = LocationManager.instance.lastRecordedLocation else {
            assert(false, "We expect currentLocation to be available")
            return false
        }
        
        guard let clubValue = Club.entityByIdentifier(club.id) else {
            return false
        }
        
        guard userLocation.distanceFromLocation(clubValue.location) < AppConfiguration.acceptableClubRadius else {
            
            var str = ""
            if let a = predefinedAction {
                switch a {
                case .AddPhoto: str = "photos"
                case .AddReport: str = "a review"
                case .AddVideo: str = "videos"
                case .NoAction: str = "these"
                }
            }
            
            infoMessage.value = ("Error" ,"To add \(str) you need to be in the \(clubValue.name)!")
            return false
        }
        
        let userCheckedIn = CheckinContext.isUserChekedInClub(clubValue)
        
        if !userCheckedIn {
            presentCheckinScreen(predefinedAction)
        }
        
        return userCheckedIn
    }
    
    private func presentCheckinScreen(predefinedAction: PostCheckinAction?) {
        let viewModel = CheckinViewModel(club: club, predefinedPostAction: predefinedAction)
        
        viewModel.postCheckinAction
            .asDriver()
            .filter{ $0 != nil }.map { $0! }
            .driveNext { action in
                
                switch action
                {
                case .NoAction:
                    self.activeViewModel.value = nil
                    
                case .AddPhoto:
                    self.addMedia(.Photo)
                    
                case .AddReport:
                    self.addReport()
                    
                case .AddVideo:
                    self.addMedia(.Video)
                    
                }
                
            }
            .addDisposableTo(disposeBag)
        
        activeViewModel.value = viewModel
    }
    
}
