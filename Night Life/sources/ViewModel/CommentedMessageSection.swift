//
//  CommentedMessageSection.swift
//  GlobBar
//
//  Created by Administrator on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxDataSources

struct CommentedMessageSection {
    
    var header : String
    var items : [Item]
    
}


extension CommentedMessageSection : AnimatableSectionModelType {
    
    typealias Item = CellViewModel
    
    var identity : String {
        return header
    }
    
    init (original: CommentedMessageSection, items: [Item]) {
        self = original
        self.items = items
    }

}