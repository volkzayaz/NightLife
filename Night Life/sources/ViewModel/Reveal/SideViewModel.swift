//
//  SideViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import Alamofire
import RxAlamofire
import RxCocoa

import ObjectMapper

class SideViewModel {
    
    private(set) var cities : Variable<[City]> = Variable([])
    private let bag = DisposeBag()
    
    var currentCityName : Driver<String> {
        return CityContext.selectedCity.asDriver()
            .filter{ $0 != nil }
            .map{ $0!.name }
    }
    
    init() {
        
        ///performing initial place population without selected city
        self.performCitiesRequest()
            .subscribeNext { [unowned self] tuple in
                
                let currentCityId = tuple.0
                self.cities.value = tuple.1
                
                ///here goes super cool logic provided by backend
                ///every place JSON contains id of club it belong to
                ///so we have to manually select current city
                CityContext.selectedCity.value = tuple.1.filter({ $0.id == currentCityId }).first
                
            }
            .addDisposableTo(bag)
     
        MessagesContext.refreshMessages()
            .addDisposableTo(bag)
    }
    
    func selectedCity(city: City) {
        
        CityContext.selectedCity.value = city
        
    }
 
    private func performCitiesRequest() -> Observable<(Int, [City])> {
        
        return LocationManager.instance
            .lastRecordedLocationObservable
            .take(1)
            .flatMap { location in
                Alamofire
                    .request(PlacesRouter.Cities(baseLocation: location)).rx_responseJSON()
                    .map { response -> (Int, [City]) in
                        
                        let cityMapper : Mapper<City> = Mapper()
                        
                        guard let rootJSON = response.1 as? [String : AnyObject],
                            let citiesJSON = rootJSON["cities"],
                            let cities = cityMapper.mapArray(citiesJSON)
                            where cities.count > 0 else {
                                ///this should never happen in app lifecycle
                                fatalError("error recognizing server response structure")
                        }
                        
                        return (cities.first!.id, cities)
                }
        }
        
    }
    
}