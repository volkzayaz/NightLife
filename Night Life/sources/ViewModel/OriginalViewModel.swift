//
//  Error.swift
//  GlobBar
//
//  Created by Andrew Seregin on 9/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift

class OriginalViewModel : NSObject{
    var errorMessage = Variable<String?>(nil)
}

protocol ErrorViewModelProtocol {
    
    var errorMessage: Variable<String?> {get set}

}