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

    static let hostName = "http://nightlife.gotests.com"
    
    static let clientId = "LZBcV40CXsWKedPwUEfYae81TIMKGZcPEzLUmfc4"
    static let clientSecret = "EqE4JoEnRBiO4Yslze9vrElueXvGURa9XqONMeObb2lh1COxgCWC5Q4X5J92ZyXHIFCgQJbzq3yWOVMCRrLj9nb6OJlS6eePyVsPW8ZaQTnBZ2BaEL7rGSyI1iMjxEJN"
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
