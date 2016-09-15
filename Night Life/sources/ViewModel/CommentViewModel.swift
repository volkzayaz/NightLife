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
    
    
    var comment : Comment?
    var message : Message
    private let bag = DisposeBag()
    
    init (message : Message) {
    
        self.message = message
        self.comment = Comment.entityByIdentifier(message.id)
        
    }

    
    mutating func createComment(message : Message, body : String) -> Comment {
        if body.characters.count > 1 {
        var comment = Comment(messageId: message.id)
        comment.body = body
        self.comment = comment
        comment.saveEntity()    
        }
        return comment!
    }
    
    func saveComment (comment : Comment, message : Message) {
        
         comment.saveEntity()
    }
    

}
    
    

