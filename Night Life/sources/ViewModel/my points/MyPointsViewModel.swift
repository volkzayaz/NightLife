//
//  MyPointsViewModel.swift
//  Night Life
//
//  Created by admin on 03.03.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift

import Alamofire
import ObjectMapper

class MyPointsViewModel : ErrorViewModelProtocol{
    
    private let bag = DisposeBag()
    
    var errorMessage = Variable<String?>(nil)
    let amountOfPointsToSubstract = Variable<Int>(100)
    var generalAmountOfPoints = Variable<Points?>(nil)

  
    let enableMinusButtonObservable: Observable<Bool>
    let enablePlusButtonObservable: Observable<Bool>
    
    let enableSubmitButtonObservable: Observable<Bool>
    
    init() {

        
        let minAmountToRedeem = 100
        
        enableMinusButtonObservable = amountOfPointsToSubstract.asObservable().map { $0 > minAmountToRedeem }
        
        enablePlusButtonObservable = [ amountOfPointsToSubstract.asObservable(),
                                       generalAmountOfPoints.asObservable()
                                        .filter{ $0 != nil }.map { $0!.points } ].combineLatest { (ints: [Int]) -> Bool in
                                            ints.first! <= ints.last!
        }
        
        
        enableSubmitButtonObservable = amountOfPointsToSubstract.asObservable().map{ $0 >= minAmountToRedeem }
        
        self.refreshPoints()
    }
    
    func removePoints () {
        
        if generalAmountOfPoints.value != nil {
        
            if amountOfPointsToSubstract.value <= generalAmountOfPoints.value?.points {
                
                Alamofire.request(PointsRouter.RemovePoints(points: amountOfPointsToSubstract.value))
                generalAmountOfPoints.value!.points -= amountOfPointsToSubstract.value
                amountOfPointsToSubstract.value = 100
            }
            else
            {
                self.errorMessage.value = "Amount of points to redeem can't exceed total amount of points"
            }
        }
    }
    
    func refreshPoints() {

        Alamofire.request(PointsRouter.GetPoints)
            .rx_responseJSON()
            .map { response -> Points in
                
                
                guard let rootJSON = response.1 as? [String:AnyObject] else {
                    
                    fatalError("Error recognizing server response")
                }
                
                let mapper = Mapper<Points>()
                guard let myPointsViewModel = mapper.map(rootJSON) else {
                    fatalError("Error parsing points from server response")
                }
                
                return myPointsViewModel
            }
            .bindTo(generalAmountOfPoints)
            .addDisposableTo(bag)
    }
    
    func increaseAmountOfPointsToSubstract() {
        
            amountOfPointsToSubstract.value += 100
    }
    
    func decreaseAmountOfPointsToSubstract() {
        
        if (amountOfPointsToSubstract.value > 1) {
        
            amountOfPointsToSubstract.value -= 100
        }
    }
}

extension MyPointsViewModel {
  
}