//
//  ViewModelCommentCell.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

struct ViewModelCommentCell {
    
    let comment : Comment
    private let bag = DisposeBag()
    
    init(comment : Comment) {
        
        self.comment = comment
    }
}


extension ViewModelCommentCell : Hashable, IdentifiableType, Equatable  {
    
    
    var hashValue : Int {
        get {
            return self.comment.id.hashValue
        }
    }
    
    var identity: String {
        return comment.body
    }
    
}

func ==(lhs: ViewModelCommentCell, rhs: ViewModelCommentCell) -> Bool {
    
    return lhs.comment == rhs.comment
    
}

