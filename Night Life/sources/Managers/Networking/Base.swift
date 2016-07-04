//
//  Base.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/16/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Alamofire
import RxSwift

struct GatewayConfiguration {

#if DEBUG
    static let hostName = ""
#elseif ADHOC
    static let hostName = ""
#else
    static let hostName = ""
#endif
    
    static let clientId = ""
    static let clientSecret = ""
}

protocol AuthorizedRouter : URLRequestConvertible {
    
    func authorizedRequest(method: Alamofire.Method,
        path: String,
        encoding: ParameterEncoding,
        body: [String : AnyObject]) -> NSMutableURLRequest
    
    func unauthorizedRequest(method: Alamofire.Method,
        path: String,
        encoding: ParameterEncoding,
        body: [String : AnyObject]) -> NSMutableURLRequest
    
}

extension AuthorizedRouter {
    
    func authorizedRequest(method: Alamofire.Method,
        path: String,
        encoding: ParameterEncoding,
        body: [String : AnyObject]) -> NSMutableURLRequest {
        
        let request = self.unauthorizedRequest(method, path: path, encoding: encoding, body: body)

        guard let token = AccessToken.token else {
            fatalError("Can't make authorized request without stored token")
        }
        
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            
        return request
    }
    
    func unauthorizedRequest(method: Alamofire.Method,
        path: String,
        encoding: ParameterEncoding,
        body: [String : AnyObject])
         -> NSMutableURLRequest {
            
            let URL = NSURL(string: GatewayConfiguration.hostName)!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
            mutableURLRequest.HTTPMethod = method.rawValue
            
            return encoding.encode(mutableURLRequest, parameters: body).0
    }
    
}
