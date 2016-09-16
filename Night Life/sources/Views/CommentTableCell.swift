//
//  CommentTableCell.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 16.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa


import DateTools

class CommentTableCell : UITableViewCell{
    
    @IBOutlet weak var coomentLabel: UILabel!

    @IBOutlet weak var createdLabel: UILabel!
    
    
    private var disposeBag = DisposeBag()
    
    func setComment(comment: Comment) {
        
        if ((InMemoryStorageArray.storage[comment.messageId]?.value.contains(comment)) != nil) {
            
            print(comment.body)
            print(comment.created)
            coomentLabel.text = comment.body
            createdLabel.text = comment.created
           
            }
        
    }
     
        
   

        
        
}