//
//  NSData+hexString.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/31/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

extension NSData {
    
    @objc(kdj_hexadecimalString)
    public var hexadecimalString: NSString {
        var bytes = [UInt8](count: length, repeatedValue: 0)
        getBytes(&bytes, length: length)
        
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        
        return NSString(string: hexString)
    }
    
}