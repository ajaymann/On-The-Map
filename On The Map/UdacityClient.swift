//
//  UdacityClient.swift
//  On The Map
//
//  Created by Ajay Mann on 25/12/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    static let sharedInstance = UdacityClient()
    
//    func loginToUdacity(username: String, password: String, completionHandlerForLogin : @escaping (_ success: Bool, _ error: Error? , _ sessionID : String?) -> Void) {
//        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
//        let session = URLSession.shared
//        let task = session.dataTask(with: request as URLRequest) { data, response, error in
//            if let error = error {
//                completionHandlerForLogin(false, error, nil)
//            }
//            
//            if let httpResponse = response as? HTTPURLResponse {
//                if httpResponse.statusCode > 399 && httpResponse.statusCode < 600 {
//                    print("error \(httpResponse.statusCode)")
//                    completionHandlerForLogin(false, NSError(domain: "returned code \(httpResponse.statusCode)", code: 1, userInfo: nil), nil)
//                }
//            }
//            
//            let dataLength = data?.count
//            let r = 5...Int(dataLength!)
//            let newData = data?.subdata(in: Range(r)) /* subset response data! */
//            
//            var parsedResults: [String: AnyObject]
//            
//            do {
//                parsedResults = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String: AnyObject]
//                if let session = parsedResults["session"] as? [String: AnyObject], let id = session["id"] as? String, let account = parsedResults["account"] as? [String: AnyObject] {
//                    self.appDelegate.uniqueKey = account["key"] as? String
//                    completionHandlerForLogin(true, nil, id)
//                }
//                
//            } catch {
//                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
//                completionHandlerForLogin(false, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo), nil)
//            }
//            
//            
//        }
//        task.resume()
//    }
    
    func taskForPost(jsonBody: String, completionHandlerForPost: @escaping (_ success: Bool, _ result : Any?, _ error: NSError?) -> Void) -> URLSessionTask {
                let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
                let session = URLSession.shared
                let task = session.dataTask(with: request as URLRequest) { data, response, error in
                    if let error = error {
                        completionHandlerForPost(false, error, nil)
                    }
        
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode > 399 && httpResponse.statusCode < 600 {
                            completionHandlerForPost(false, NSError(domain: "returned code \(httpResponse.statusCode)", code: 1, userInfo: nil), nil)
                        }
                    }
        
                    let dataLength = data?.count
                    let r = 5...Int(dataLength!)
                    let newData = data?.subdata(in: Range(r)) /* subset response data! */
    }

}
