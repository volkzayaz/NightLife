//
//  SurvayScrollView.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class SurvayScrollView : UIScrollView {
   
    @IBOutlet var partyStatusContainer: UIView!
    @IBOutlet var fullnessContainer: UIView!
    @IBOutlet var musicContainer: UIView!
    @IBOutlet var genderRatioContainer: UIView!
    @IBOutlet var coverChargeContainer: UIView!
    @IBOutlet var queueLengthContainer: UIView!
    
    private let partyStatusView : RadioButtonGroup<PartyStatus> = RadioButtonGroup()
    private let fulnessView : DiscreetStepper<Fullness> = DiscreetStepper()
    private let musicView : RadioButtonGroup<Music> = RadioButtonGroup()
    private let genderRatioView : DiscreetStepper<GenderRatio> = DiscreetStepper()
    private let coverChargeView : RadioButtonGroup<CoverCharge> = RadioButtonGroup()
    private let queueView : RadioButtonGroup<QueueLine> = RadioButtonGroup()
    
    @IBOutlet var continueSurvayButton: UIButton!
    @IBOutlet var completeSurvayButton: UIButton!
    @IBOutlet var submitSurvayButton: UIButton!
    
    var viewModel : CreateReportViewModel!
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ///party staus
        
        partyStatusContainer.embbedViewAsContainer(partyStatusView)
        
        partyStatusView.addOptions([
            .Yes,
            .No
            ])
        
        ///fulness
        
        fullnessContainer.embbedViewAsContainer(fulnessView)
        
        fulnessView.minimumColor = UIColor.orangeColor()
        fulnessView.maximumColor = UIColor.whiteColor()
        fulnessView.addOptions([Fullness.Empty, Fullness.Low, Fullness.Crowded, Fullness.Packed])
        
        ///music
        musicContainer.embbedViewAsContainer(musicView)
        
        musicView.addOptions([
                .NoMusic,
                .DJ_EDM_House,
                .DJ_disco,
                .DJ_hip,
                .Pop,
                .LiveBand,
                .Karaoke,
                .Other,
            ])
        
        ///gender ratio
        
        genderRatioContainer.embbedViewAsContainer(genderRatioView)
        genderRatioView.minimumColor = UIColor(red: 67, green: 0, blue: 100)
        genderRatioView.maximumColor = UIColor(red: 34, green: 123, blue: 151)
        genderRatioView.addOptions([
            .MostlyGuys,
            .MoreGuys,
            .Balanced,
            .MoreLadies,
            .MostlyLadies
            ])
        
        ///cover charge
        coverChargeContainer.embbedViewAsContainer(coverChargeView)
        
        coverChargeView.addOptions([
            .Free,
            .Small,
            .Moderete,
            .Big
            ])
        
        ///queue
        queueLengthContainer.embbedViewAsContainer(queueView)
        
        queueView.addOptions([
            .NoQueue,
            .Short,
            .Long,
            .Enormous
            ])
        
        ///validation closure
        let validationClosure = { (ar: [CustomStringConvertible?]) -> Bool in
            return ar.filter{ $0 != nil }.count == ar.count
        }

        ///complete survay after 3 questions actions
        let completeSurvayObservable = completeSurvayButton
            .rx_tap
            .filter { [unowned self] _ in
                let isValid = validationClosure([
                    self.partyStatusView.selectedOption,
                    self.queueView.selectedOption,
                    self.coverChargeView.selectedOption
                    ])
                
                if !isValid {
                    self.viewModel.errorMessage.value = "Please answer the questions before completing survey"
                }
                
                return isValid
            }
            .map { [unowned self] _ -> Report in
                let partyStatus = self.partyStatusView.selectedOption
                let coverCharge = self.coverChargeView.selectedOption
                let queue = self.queueView.selectedOption
                
                return Report(partyOnStatus: partyStatus,
                    fullness: nil,
                    musicType: nil,
                    genderRatio:  nil,
                    coverCharge: coverCharge,
                    queue:  queue)
            }
        
        ///complete survay after 6 questions actions
        let submitSurvayObservable = submitSurvayButton
            .rx_tap
            .filter { [unowned self] _ in
                let isValid = validationClosure([
                    self.partyStatusView.selectedOption,
                    self.queueView.selectedOption,
                    self.coverChargeView.selectedOption,
                    self.genderRatioView.selectedOption,
                    self.fulnessView.selectedOption,
                    self.musicView.selectedOption
                    ])
                
                if !isValid {
                    self.viewModel.errorMessage.value = "Please answer the questions before completing survey"
                }
                
                return isValid
            }.map { [unowned self] _ -> Report in
                
                let partyStatus = self.partyStatusView.selectedOption
                let fullness = self.fulnessView.selectedOption
                let music = self.musicView.selectedOption
                let genderRatio = self.genderRatioView.selectedOption
                let coverCharge = self.coverChargeView.selectedOption
                let queue = self.queueView.selectedOption
                
                return Report(partyOnStatus: partyStatus, fullness: fullness, musicType: music, genderRatio:  genderRatio, coverCharge: coverCharge, queue:  queue)
            }

        
        Observable.of(
            submitSurvayObservable,
            completeSurvayObservable
            ).merge().subscribeNext { [unowned self] report in
                
                self.viewModel.submitReport(report)
                
            }
            .addDisposableTo(disposeBag)

        
        ///continue survay button actions
        continueSurvayButton.rx_tap
            .filter { [unowned self] _ in
                let isValid = validationClosure([
                    self.partyStatusView.selectedOption,
                    self.queueView.selectedOption,
                    self.coverChargeView.selectedOption
                    ])
                
                if !isValid {
                    self.viewModel.errorMessage.value = "Please answer the questions before proceeding"
                }
                
                return isValid
            }
            .subscribeNext{ [unowned self] _ in
                UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                    self.contentOffset.y += self.frame.size.height
                    }) { _ in
                        self.viewModel.moveToNextQuestionPage()
                    }
            }
            .addDisposableTo(disposeBag)
    }

    func configureUI() {
        ///CONTINUE SURVAY
        continueSurvayButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), atIndex: 0)
        
        ///COMPLETE SURVEY
        completeSurvayButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), atIndex: 0)
        
        ///SUBMIT SURVEY
        submitSurvayButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), atIndex: 0)
        
    }
    
    func layoutSubLayers() {
        continueSurvayButton.layer.sublayers?.forEach{ [weak s = continueSurvayButton] l in
            l.frame = s!.bounds
        }
        
        completeSurvayButton.layer.sublayers?.forEach{ [weak s = completeSurvayButton] l in
            l.frame = s!.bounds
        }
        
        submitSurvayButton.layer.sublayers?.forEach{ [weak s = submitSurvayButton] l in
            l.frame = s!.bounds
        }
    }
    
}

extension UIView {
    
    func embbedViewAsContainer(view: UIView) {
        
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint1 = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let constraint2 = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        let constraint3 = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        let constraint4 = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        
        self.addConstraints([constraint1,constraint2,constraint3,constraint4])
    }
    
}