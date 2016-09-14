//
//  CommentViewModel.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 14.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//
import RxSwift

import Alamofire
import RxAlamofire

struct CommentViewModel {
    
    
    var comment : Comment
    
    private let bag = DisposeBag()
    
    init (message : Message, comment: Comment) {
    
    
        self.comment = comment
        self.comment.messageId = message.id        
        self.comment.saveEntity()
        
    }

    
    
    
    func saveComment (comment : Comment, message : Message) {
        
        comment.saveEntity()
    }
    

}
    
    

