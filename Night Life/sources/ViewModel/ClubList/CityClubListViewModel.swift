//
//  MainClubListViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import RxCocoa

import Alamofire
import ObjectMapper

class CityClubListViewModel {
    
    var title : Driver<String> {
        return CityContext.selectedCity.asDriver()
            .map{ $0?.name ?? "List of Places" }
    }
    
    let clubsViewModel = ClubListViewModel()
    let bag = DisposeBag()
    
    init() {
        
        CityContext.selectedCity.asObservable()
            .filter { $0 != nil }.map { $0! }
            .distinctUntilChanged { $0 == $1 }
            .map { .InCity(city: $0) }
            .bindTo(clubsViewModel.clubsRouter)
            .addDisposableTo(bag)
        
    }
}
    
