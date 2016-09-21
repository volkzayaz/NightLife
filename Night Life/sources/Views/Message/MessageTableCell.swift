//
//  MessageTableCell.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire

import DateTools

class MessageTableCell : UITableViewCell {
    
   
    @IBOutlet weak var unreadOverlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    private var disposeBag = DisposeBag()
    
    func setMessage(message: Message) {
        
        if InMemoryStorageArray.storage[message.id] == nil {
            InMemoryStorageArray.storage[message.id] = Variable([])
        }
        
        guard let messageObservable = message.observableEntity()?.asObservable() else {
            fatalError("Can't populate cell without message observable")
        }
        
        messageObservable.map { $0.title }
            .bindTo(titleLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        messageObservable.map { $0.body }
            .bindTo(bodyLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        messageObservable.map { $0.created?.timeAgoSinceNow() ?? "" }
            .bindTo(createdLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        messageObservable.map { $0.isRead }
            .bindTo(unreadOverlayView.rx_hidden)
            .addDisposableTo(disposeBag)
       
        let commentCount = InMemoryStorageArray.storage[message.id]!.asObservable()
            .flatMapLatest { (comments : [Comment]) -> Observable<Int> in
                comments
                    .flatMap { Observable.just($0) }
                .combineLatest { comments in
                let filteredComments : [Comment] = comments.filter{_ in comments.count > 0}
                return filteredComments.count
                
                }
            }

        commentCount
            .map { String($0) }
            .bindTo(commentsCountLabel.rx_text)
            .addDisposableTo(disposeBag)
        
    }
    
}

