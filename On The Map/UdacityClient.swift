//
//  UdacityClient.swift
//  On The Map
//
//  Created by Ajay Mann on 25/12/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {

    func taskForPost(url: String, jsonBody: String?, method : String, completionHandlerForPost: @escaping (_ success: Bool, _ result : [String: Any]?, _ error: NSError?) -> Void){
                let request = NSMutableURLRequest(url: URL(string: url)!)
                request.httpMethod = method
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonBody?.data(using: String.Encoding.utf8)
                let session = URLSession.shared
                let task = session.dataTask(with: request as URLRequest) { data, response, error in
                    
                    if let error = error {
                        completionHandlerForPost(false, nil, error as NSError?)
                    }
        
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode > 399 && httpResponse.statusCode < 600 {
                            completionHandlerForPost(false, nil, NSError(domain: "returned code \(httpResponse.statusCode)", code: 1, userInfo: nil))
                        }
                    }
        
                    let dataLength = data?.count
                    let r = 5...Int(dataLength!)
                    let newData = data?.subdata(in: Range(r)) /* subset response data! */
                    var parsedResults: [String: AnyObject]
                    
                    do {
                        parsedResults = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String: AnyObject]
                        completionHandlerForPost(true, parsedResults, nil)
                    } catch {
                        let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                        completionHandlerForPost(false, nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
                    }
                    
        }
        task.resume()
    }
    
    func taskForLogout(url: String, completionHandlerForLogout : @escaping (_ success: Bool, _ result: [String:Any]?, _ err: NSError?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! as [HTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                //
                completionHandlerForLogout(false, nil, error as NSError?)
                return
            }
            let dataLength = data?.count
            let r = 5...Int(dataLength!)
            let newData = data?.subdata(in: Range(r)) /* subset response data! */
            completionHandlerForLogout(true, newData as? [String:Any], nil)
        }
        task.resume()
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}


