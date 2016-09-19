//
//  Error.swift
//  GlobBar
//
//  Created by Andrew Seregin on 9/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift

protocol ErrorViewModelProtocol {
    
    var errorMessage: Variable<String?> {get set}

}