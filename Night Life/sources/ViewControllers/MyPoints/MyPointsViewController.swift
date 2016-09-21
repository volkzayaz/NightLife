//
//  MyPointsViewController.swift
//  Night Life
//
//  Created by admin on 02.03.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SWRevealViewController
import QuartzCore


class MyPointsViewController<T : ErrorHandler>: UIViewController, UITextFieldDelegate{
    
  private let kScrollUP:Int = 170
    
  @IBOutlet weak var scrollView: UIScrollView!
    
  @IBOutlet weak var pointsTopLbl: UILabel!
  @IBOutlet weak var pointsBottomLbl: UILabel!
  
  @IBOutlet weak var pointsMinusBtn: UIButton!
  @IBOutlet weak var pointsPlusBtn: UIButton!
  @IBOutlet weak var submitBtn: UIButton!
    
  @IBAction func minusBtnClick(sender: AnyObject) {

      viewModel.decreaseAmountOfPointsToSubstract()
    
  }
    
  @IBAction func plusBtnClick(sender: AnyObject) {
    
      viewModel.increaseAmountOfPointsToSubstract()
    
  }
  @IBAction func submitBtnClick(sender: AnyObject) {

    viewModel.removePoints()
  }
  
    var viewModel = MyPointsViewModel()

  private let bag = DisposeBag()

    
    override func viewDidLoad() {

    super.viewDidLoad()

    self.showInfoMessage(withTitle: "alert", "PLEASE REDEEM THE POINTS AT A PARTNER VENUE") {
        
        
    }
        
    viewModel.amountOfPointsToSubstract.asObservable()
        .map{ "\($0)" }
        .bindTo(pointsBottomLbl.rx_text)
        .addDisposableTo(bag)
    
    viewModel.enableMinusButtonObservable
        .bindTo(pointsMinusBtn.rx_enabled)
        .addDisposableTo(bag)
    
    viewModel.enableSubmitButtonObservable
        .bindTo(submitBtn.rx_enabled)
        .addDisposableTo(bag)
    
    viewModel.generalAmountOfPoints.asObservable()
      .filter{ $0 != nil }
      .map{"\($0!.points)"}
      .bindTo(pointsTopLbl.rx_text)
      .addDisposableTo(bag)
  }
}



protocol ErrorHandler {
    
    associatedtype ViewModel : OriginalViewModel
    
    var viewModel: ViewModel { get set }
}

