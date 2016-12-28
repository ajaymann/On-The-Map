//
//  ParseClient.swift
//  On The Map
//
//  Created by Ajay Mann on 26/12/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import Foundation
class ParseClient : NSObject {
    
    func taskForPost(url: String, jsonBody: String?, method : String, completionHandlerForPost: @escaping (_ success: Bool, _ result : [String: Any]?, _ error: NSError?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.httpBody = jsonBody?.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandlerForPost(false, nil, error as NSError?)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode > 399 && httpResponse.statusCode < 600 {
                    completionHandlerForPost(false, nil, error as NSError?)
                } else if httpResponse.statusCode > 199 && httpResponse.statusCode < 300 {
                    completionHandlerForPost(true, nil, nil)
                }
            }
            
            var parsedResults: [String : AnyObject]
            do {
                parsedResults = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                completionHandlerForPost(true, parsedResults, nil)
                }
            catch {
                _ = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            }
        }
        task.resume()
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
