//
//  CommentedMessageViewModel.swift
//  GlobBar
//
//  Created by Administrator on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

class  CommentedMessageViewModel {
    
    var messageComments : Variable <[Comment]> = Variable([])
    
    init() {
        
        CommentStorage.commentStorage.values
        
//        self.messageComments.value = ...
    }
    
}