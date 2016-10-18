//
//  ParseClient.swift
//  On The Map
//
//  Created by Ajay Mann on 16/10/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // authentication state
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
}
 // func taskForGETMethod (parameters: [String: AnyObject])
    
    private func ParseURLFromParameters(parameters : [String: AnyObject]) -> URL {
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}
