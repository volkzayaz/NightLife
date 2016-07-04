//
//  InvitationViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import Alamofire
import RxAlamofire

enum InvitationError : ErrorType {
    
    //case NoFacebookToken
    case NoPublishPermissions
    
}

class InvitationViewModel {
    
    private let activityIndicator = ViewIndicator()
    var activityDriver: Driver<Bool> {
        return activityIndicator.asDriver()
    }
    let message: Variable<String?> = Variable(nil)
    
    private let bag = DisposeBag()
    
    func inviteOn(controller: UIViewController) {
        
        invitationObservable(controller)
            .map { a in let b: String? = a; return b }
            .bindTo(message)
            .addDisposableTo(bag)
        
    }
    
    private func invitationObservable(controller: UIViewController) -> Observable<String> {
        
        return Alamofire.request(FacebookInvitationRouter.SendInvitation)
            .rx_responseJSON()
            .trackView(activityIndicator)
            .flatMap { response -> Observable<String> in
                guard let data = response.1["data"] as? String else {
                    return Observable.just("Error recognizing response. Please try again later")
                } 
                
                if data == "invalid token" {
                    return Observable.error(InvitationError.NoPublishPermissions)
                }
                
                return Observable.just("Invitation was succesfully posted")
            }
            .catchError { [unowned self] er -> Observable<String> in
                guard let invitationError = er as? InvitationError else { return Observable.just("\(er)") }
                
                switch invitationError {
                    
                case .NoPublishPermissions:
                    return FacebookAuthenticator
                        .reauthentiacteForPublishObservable(onController: controller)
                        .trackView(self.activityIndicator)
                        .flatMap { data -> Observable<AnyObject> in
                            return Alamofire.request(FacebookInvitationRouter.UpdateToken(token: data.token))
                                .rx_responseJSON().map{ $0.1 }
                        }
                        .flatMap { [unowned self] _ in
                            ///FIXME: check for retin count for controller var
                            self.invitationObservable(controller)
                        }
                    
                }
            }
        
    }
    
}