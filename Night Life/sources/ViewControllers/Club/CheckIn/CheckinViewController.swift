//
//  CheckinViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/23/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class CheckinViewController : UIViewController {
    
    var viewModel : CheckinViewModel!
    
    private let bag = DisposeBag()
    
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var checkinsCountLabel: UILabel!
    @IBOutlet weak var checkinQuestionLabel: UILabel!
    @IBOutlet weak var checkinQuestionCheckmark: UIImageView!
    
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var clubAdressLabel: UILabel!
    @IBOutlet weak var dancingClubLabel: UILabel!
    @IBOutlet weak var todayCheckinLabel: UILabel!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    
    @IBOutlet weak var lastCheckedInUsersView: CircularIconsGroupView!
    
    @IBOutlet weak var chekinAffirmativeButton: UIButton!
    @IBOutlet weak var checkinNegativeButton: UIButton!
    
    @IBOutlet weak var createReportButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var recordVideoButton: UIButton!
    
    @IBOutlet weak var broadcastLocationButton: CheckButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()

        configureUI()
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil { assert(false) /*view model must be initialized before using view controller*/  }
        
        ///hidden vs. shown action buttons
        
        let hideObservable = viewModel.checkinControlsShown.asObservable()
        let showObservable = hideObservable.map { !$0 }
        
        showObservable
            .bindTo(chekinAffirmativeButton.rx_hidden)
            .addDisposableTo(bag)
        
        showObservable
            .bindTo(broadcastLocationButton.rx_hidden)
            .addDisposableTo(bag)
        
        hideObservable
            .bindTo(createReportButton.rx_hidden)
            .addDisposableTo(bag)
        
        hideObservable
            .bindTo(takePhotoButton.rx_hidden)
            .addDisposableTo(bag)
        
        hideObservable
            .bindTo(recordVideoButton.rx_hidden)
            .addDisposableTo(bag)
        
        hideObservable
            .filter { !$0 }
            .subscribeNext{ [unowned self] _ in
                self.checkinQuestionLabel.text = "YOU'VE CHEKED IN HERE!"
                self.checkinQuestionLabel.font = UIFont(name: "Raleway-Medium", size: 15)
                self.checkinQuestionLabel.textColor = UIColor(fromHex: 0xf07800)
            }
            .addDisposableTo(bag)
        
        hideObservable
            .bindTo(checkinQuestionCheckmark.rx_hidden)
            .addDisposableTo(bag)
        
        ///loading spinner
        
        viewModel.loadingIndicator.asObservable()
            .bindTo(loadingSpinner.rxex_animating)
            .addDisposableTo(bag)
        
        guard let observableClub = viewModel.club.observableEntity() else {
            fatalError("Can't present Checkin screen without stored club with id \(viewModel.club.id)")
        }
        
        ///cover photo
        observableClub.asDriver()
            .map{ $0.coverPhotoURL }
            .distinctUntilChanged()
            .flatMap{ ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(coverPhotoImageView.rx_imageAnimated(kCATransitionFade))
            .addDisposableTo(bag)
        
        ///logo
        observableClub.asDriver()
            .map{ $0.logoImageURL }
            .distinctUntilChanged()
            .flatMap{ ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(logoImageView.rx_imageAnimated(kCATransitionFade))
            .addDisposableTo(bag)
        
        ///name
        observableClub.asDriver()
            .map{ $0.name }
            .drive(clubNameLabel.rx_text)
            .addDisposableTo(bag)
        
        ///addres
        observableClub.asDriver()
            .map{ $0.adress }
            .drive(clubAdressLabel.rx_text)
            .addDisposableTo(bag)

        ///checkin count
        observableClub.asDriver()
            .map{ String($0.checkinsCount) }
            .drive(checkinsCountLabel.rx_text)
            .addDisposableTo(bag)
        
        ///likes count
        observableClub.asDriver()
            .map{ String($0.likesCount) }
            .drive(likesCountLabel.rx_text)
            .addDisposableTo(bag)
        
        ///last checked in users
        
        observableClub.asDriver()
            .flatMap { club in
                club.lastCheckedInUsers /// all lastCheckedInUsers
                    .flatMap { ///filtering out users taht are not in storage
                        $0.observableEntity()?.asDriver() /// getting observable user from storage
                    }
                    .combineLatest { actualUsers in ///mapping true users to their picture URLs
                        actualUsers.map { $0.pictureURL! }
                    }
            }
            .driveNext { [weak v = self.lastCheckedInUsersView] icons in
                v?.addIconURLs(icons)
            }
            .addDisposableTo(bag)
        
        ///error presenting
        viewModel.errorMessage.asDriver()
            .filter { $0 != nil }.map { $0! }
            .driveNext { [unowned self] message in
                self.showInfoMessage(withTitle: "Error", message)
            }
            .addDisposableTo(bag)
    }
    
    @IBAction func yes(sender: AnyObject) {
        viewModel.userChekedIn(!broadcastLocationButton.selected)
    }

    @IBAction func takePhoto(sender: AnyObject) {
        viewModel.addPhotoClicked()
    }
    
    @IBAction func createReport(sender: AnyObject) {
        viewModel.addReportClicked()
    }
    
    @IBAction func noClicked(sender: AnyObject) {
        viewModel.noClicked()
    }
}

extension CheckinViewController {
    
    func configureUI() {
        
        checkmarkImageView.layer.borderWidth = 1
        checkmarkImageView.layer.borderColor = UIColor.whiteColor().CGColor
        checkmarkImageView.layer.cornerRadius = checkmarkImageView.frame.size.height / 2

        ///bottom buttons
        let font = UIConfiguration.appFontOfSize(16)
        let bigFont = UIConfiguration.appFontOfSize(21)
        let color = UIColor.whiteColor()
        
        ///YES
        chekinAffirmativeButton.setTitleColor(color, forState: .Normal)
        chekinAffirmativeButton.titleLabel?.font = bigFont
        chekinAffirmativeButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), atIndex: 0)
        chekinAffirmativeButton.setTitle("YES", forState: .Normal)
        
        ///CREATE REPORT
        createReportButton.setTitleColor(color, forState: .Normal)
        createReportButton.titleLabel?.font = font
        createReportButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), atIndex: 0)
        createReportButton.setTitle("CREATE REPORT", forState: .Normal)

        ///NO
        checkinNegativeButton.setTitleColor(color, forState: .Normal)
        checkinNegativeButton.titleLabel?.font = bigFont
        checkinNegativeButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0x898989), to: UIColor(fromHex: 0x585756)), atIndex: 0)
        checkinNegativeButton.setTitle("NO", forState: .Normal)

        ///add photo
        takePhotoButton.setTitleColor(color, forState: .Normal)
        takePhotoButton.titleLabel?.font = font
        takePhotoButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), atIndex: 0)
        takePhotoButton.setTitle("ADD PHOTO", forState: .Normal)
        
        ///checkin question
        checkinQuestionLabel.text = "CHECK IN?"
        checkinQuestionLabel.font = UIConfiguration.appSecondaryFontOfSize(21)
        
        ///club attributes
        clubNameLabel.font = UIConfiguration.appSecondaryFontOfSize(23)
        clubAdressLabel.font = UIConfiguration.appFontOfSize(10)
        dancingClubLabel.font = UIConfiguration.appSecondaryFontOfSize(15)
        todayCheckinLabel.font = UIConfiguration.appSecondaryFontOfSize(14)
        
        ///checkin checkmark color
        checkinQuestionCheckmark.image? = (checkinQuestionCheckmark.image?.imageWithRenderingMode(.AlwaysTemplate))!
        checkinQuestionCheckmark.tintColor = UIColor(fromHex: 0xf07800)
    }
    
    override func viewDidLayoutSubviews() {
        let buttonsForResize = [checkinNegativeButton, chekinAffirmativeButton, takePhotoButton, createReportButton]
        
        buttonsForResize.forEach{ view in
            view.layer.sublayers?.forEach { $0.frame = view.bounds }
        }
        
        logoImageView.layer.cornerRadius = logoImageView.frame.size.height / 2
    }
    
}
