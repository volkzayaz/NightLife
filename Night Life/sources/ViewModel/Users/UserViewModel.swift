//
//  UserViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/22/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import RxDataSources

enum UserViewModelActionType {
    
    case SendFollowRequest
    case AcceptFollowRequest
    case DeclineFollowRequest
    
    case Unsubscribe
    case Block
    
    func description() -> (String, String) {
        switch self {
        case .AcceptFollowRequest:
            return ("Accept", "accept")
            
        case .Block:
            return ("Block", "decline")
            
        case .DeclineFollowRequest:
            return ("Decline", "decline")
            
        case .SendFollowRequest:
            return ("Subscribe", "accept")
            
        case .Unsubscribe:
            return ("Unsubscribe", "decline")
        }
    }
}

typealias UserViewModelAction = (user: User, type:UserViewModelActionType)

struct UserViewModel {
    
    let performedAction: Variable<UserViewModelAction?> = Variable(nil)
    
    let user: User
    let actions: [UserViewModelActionType]
    
    init(user: User, actions: [UserViewModelActionType]) {
        assert(actions.count <= 2, "UserViewModel supports up to two actions")
        self.actions = actions
        
        self.user = user
        
//        self.performedAction.asObservable().debug()
//            .subscribeNext {_ in
//        }
        
    }

    func actionPerformedAtIndex(index: Int) {
        let action = actions[index]
        
        performedAction.value = (user, action)
    }
    
}

extension UserViewModel : IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Int {
        return user.id
    }
    
}
func ==(lhs: UserViewModel, rhs: UserViewModel) -> Bool {
    return lhs.user.id == rhs.user.id && lhs.actions == rhs.actions
}