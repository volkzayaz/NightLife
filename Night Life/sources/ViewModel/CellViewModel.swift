//
//  CellViewModel.swift
//  GlobBar
//
//  Created by Administrator on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

struct CellViewModel {
    
    private (set) var message : Message
    private let bag = DisposeBag()
    
    var commentedMessages : Observable<Bool> {
        
        return self.commentedMessages as! Observable
    
    }
    
//    var switchLikeStatus : Observable<Bool> {
//        
//        return AlbumStorage.storageLikedAlbumId.asObservable()
//            .map{ (liked : Set<Int>) -> Bool in
//                return liked.contains(self.album.albumId!)
//        }

    
    
 
    init (message : Message) {
        
        self.message = message
    }
    
}

extension CellViewModel : IdentifiableType, Equatable {
    
    var  identity : String {
        return "CellViewModel"
    }
 
}

func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
    return lhs.message == rhs.message
}