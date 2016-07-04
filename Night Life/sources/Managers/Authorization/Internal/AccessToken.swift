//
//  AccessToken.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/6/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import CryptoSwift

enum AccessToken {}
extension AccessToken {
    
    private static let accountName = "http://nightlifedev.gotests.com"
    
    private static let aesKey = "secret0key010100"
    private static let aesIV = "9123456749012343"
    
    private static var tokenString: String? = nil
    
    static var token : String? {
        get {
 
            if (tokenString == nil) {
 
                guard let encryptedToken = NSUserDefaults.standardUserDefaults().objectForKey(accountName) as? String,
                    let decryptedToken = try? encryptedToken.aesDecrypt(aesKey, iv: aesIV) else {
                        return nil
                }
                
                tokenString = decryptedToken
            }
            
            return tokenString
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(accountName)
                tokenString = nil
            }
            else {
                
                let encryptedToken = try? newValue?.aesEncrypt(aesKey, iv: aesIV)
                
                NSUserDefaults.standardUserDefaults().setObject(encryptedToken!, forKey: accountName)
            }
            
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}
