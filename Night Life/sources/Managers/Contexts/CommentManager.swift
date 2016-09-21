
//  ComentsManager.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 14.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//
//
//import Foundation
//import RxCocoa
//import RxSwift
//
//class CommentManager {
//
//    static var commentsWithMessages : [Int : Variable<Comment>] = [:]
//
//    static func populateComments(messages: [Message]) {
//
//        messages.forEach { (message) in
//
//            guard commentsWithMessages[message.id] == nil else { return }
//
//            self.commentsWithMessages[message.id] = Variable(Comment(messageId: message.id))
//        }
//
//    }
//
//    static func setComment(message: Message, comment : Comment) {
//
//        commentsWithMessages[message.id]?.value = comment
//    }
//
//
//
//
//}