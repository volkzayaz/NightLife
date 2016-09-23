//
//  CommentTableCell.swift
//  GlobBar
//
//  Created by Administrator on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CommentTableCell : UITableViewCell {
    
    @IBOutlet weak var unreadOverLayView: UIView!
    
    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var createdLabel: UILabel!
    
    private var bag = DisposeBag()
    
    func setCommentedMessage (cellViewModel : CellViewModel) {
        
    }
    
    
    
//    func setMessage(message: Message) {
//        
//        guard let messageObservable = message.observableEntity()?.asObservable() else {
//            fatalError("Can't populate cell without message observable")
//        }
//        
//        messageObservable.map { $0.title }
//            .bindTo(titleLabel.rx_text)
//            .addDisposableTo(disposeBag)
//        
//        messageObservable.map { $0.body }
//            .bindTo(bodyLabel.rx_text)
//            .addDisposableTo(disposeBag)
//        
//        messageObservable.map { $0.created?.timeAgoSinceNow() ?? "" }
//            .bindTo(createdLabel.rx_text)
//            .addDisposableTo(disposeBag)
//        
//        messageObservable.map { $0.isRead }
//            .bindTo(unreadOverlayView.rx_hidden)
//            .addDisposableTo(disposeBag)
//        
//    }

    
    
    
    
}
