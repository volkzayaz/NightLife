//
//  CreateReport.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift

class CreateReportViewController : UIViewController {
    
    var viewModel : CreateReportViewModel!
    
    @IBOutlet var questionNumbersLabels: [UILabel]!
    @IBOutlet weak var scrollView: SurvayScrollView!
    
    @IBOutlet weak var clubLogoImageView: UIImageView!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var clubAdressLabel: UILabel!
    @IBOutlet weak var questionNumberLabel: UILabel!
    private let bag = DisposeBag()
    
    override func loadView() {
        super.loadView()
     
        scrollView.configureUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil { assert(false,"view model must be initialized before using view controller") }
        
        scrollView.viewModel = viewModel
        
        questionNumbersLabels.forEach { label in
            label.layer.cornerRadius = label.frame.size.height / 2
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.whiteColor().CGColor
//            label.font = UIConfiguration.appSecondaryLightFontOfSize(24)
        }
        
        ///ERROR MESSAGE BINDING
        viewModel.errorMessage.asDriver()
            .filter{ $0 != nil }.map { $0! }
            .driveNext { [unowned self] message in
                self.showInfoMessage(withTitle: "Error", message)
            }
            .addDisposableTo(bag)
        
        ///CLUB data binding
        ImageRetreiver.imageForURLWithoutProgress(viewModel.clubLogoImageURL)
            .drive(clubLogoImageView.rx_image)
            .addDisposableTo(bag)
        
        clubNameLabel.text = viewModel.clubName
        clubAdressLabel.text = viewModel.clubAdress
        
        viewModel.questionStatusNumber.asObservable()
            .map{ "\($0)" }
            .bindTo(questionNumberLabel.rx_text)
            .addDisposableTo(bag)
        
        self.title = "Bar Rating"
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.layoutSubLayers()
        clubLogoImageView.layer.cornerRadius = clubLogoImageView.frame.size.height / 2
    }
 
}
