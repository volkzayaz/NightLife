//
//  ReportDetailsViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/3/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class ReportDetailsViewController: UIViewController {

    var viewModel: ReportDetailsViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var reportTableView: UITableView!
    @IBOutlet weak var autorImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    
    @IBOutlet weak var gradientContainer: UIView!
    private weak var clubDescriptionGradintLayer : CALayer? = nil
    
    @IBOutlet weak var clubCoverImageView: UIImageView!
    @IBOutlet weak var clubLogoImageView: UIImageView!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var clubAdressLabel: UILabel!
    @IBOutlet weak var likeDislike: UISwitch!
    
    private var tableViewGradientLayer = UIConfiguration.gradientLayer(UIColor(fromHex:0x303030), to: UIColor(fromHex:0x0f0f0f))
    
    override func loadView() {
        super.loadView()
        
        setUpUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if viewModel == nil { assert(false) /*view model must be initialized before using view controller*/  }
        
        Observable.just(viewModel.dataSource)
            .bindTo(reportTableView.rx_itemsWithCellIdentifier("report cell", cellType: ReportDetailsTableCell.self))
                { (_, element: ReportData, cell: ReportDetailsTableCell) in
                    
                    cell.iconImageView.image = UIImage(named: element.iconName)
                    cell.firstLabel.text = element.title
                    cell.detailsLabel.text = element.description
                    
            }
            .addDisposableTo(disposeBag)
        

        
        ///club images
        ImageRetreiver.imageForURLWithoutProgress(viewModel.club.coverPhotoURL)
            .drive(clubCoverImageView.rx_image)
            .addDisposableTo(disposeBag)
        
        ImageRetreiver.imageForURLWithoutProgress(viewModel.club.logoImageURL)
            .drive(clubLogoImageView.rx_image)
            .addDisposableTo(disposeBag)
        
        ///Club basic info
        clubNameLabel.text = viewModel.club.name
        clubAdressLabel.text = viewModel.club.adress
        
        ///author data binding
        if let author = User.entityByIdentifier(viewModel.report.postOwnerId) {
            
            ImageRetreiver.imageForURLWithoutProgress(author.pictureURL!)
                .drive(autorImageView.rx_image)
                .addDisposableTo(disposeBag)
            
            authorNameLabel.text = author.username
        }
        
        dateLabel.text = UIConfiguration.stringFromDate((viewModel.report.createdDate)!)
        
        LikeManager.arrayOfLikes.asObservable()
            .subscribeNext{[weak self](ids : [Int]) in
                
                self?.likeDislike.setOn(ids.contains(self!.viewModel.report.id), animated: false)
                
            }.addDisposableTo(disposeBag)
        
        self.likeDislike.rx_value.asObservable()
            .subscribeNext{[weak self](value : Bool) in
                
                LikeManager.appendLikeDislike(self!.viewModel.report.id, valueOfSwitch: value)

            }.addDisposableTo(disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableViewGradientLayer.frame = CGRect(origin: CGPointZero, size: reportTableView.bounds.size)
        tableViewGradientLayer.cornerRadius = 0
        clubLogoImageView.layer.cornerRadius = clubLogoImageView.frame.size.height / 2
        clubDescriptionGradintLayer?.frame = gradientContainer.bounds
        autorImageView.layer.cornerRadius = autorImageView.frame.size.height / 2
        
    }

}

extension ReportDetailsViewController {
    
    static func instantiate() -> ReportDetailsViewController {
        
        let storyboard = UIStoryboard(name: "ClubFeedDetails", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("ReportDetailsViewController") as! ReportDetailsViewController
        
    }
    
    func setUpUI() {
        self.title = "Review Detail"

        let gradientContentView = UIView()
        gradientContentView.layer.addSublayer(tableViewGradientLayer)
        reportTableView.backgroundView = gradientContentView
        
        let layer = UIConfiguration.gradientLayer(UIColor(white: 0, alpha: 0), to: UIColor(white: 0, alpha: 1))
        layer.cornerRadius = 0
        clubDescriptionGradintLayer = layer
        
        gradientContainer.layer.insertSublayer(layer, atIndex: 0)
        
    }
    
}
