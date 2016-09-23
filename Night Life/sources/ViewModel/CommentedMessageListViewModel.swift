//
//  CommentedMessageListViewModel.swift
//  GlobBar
//
//  Created by Administrator on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources


class CommentedMessageListViewModel {
    
    private let bag = DisposeBag()
    var sections : Variable<[CommentedMessageSection]> = Variable([])
    
    init () {
        
        CommentStorage.getCommentedMessages()
            
//            .asObservable()
//            .map { (messagesIds : [Int]) -> Observable<[Message]> in
//                
//                
//                return messagesIds.map { (map : Int) -> Message in
//                    return Message (map : map)
//                }
        
//        }
        
                   
    }
    
}