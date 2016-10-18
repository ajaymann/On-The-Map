//
//  LoginViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 16/10/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        configureUI()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        configureUI()
    }
    
    func configureUI() {
        if usernameTextField.text == "" || passwordTextField.text == "" {
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
        } else {
            loginButton.isEnabled = true
            loginButton.alpha = 1
        }
    }
    
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
    
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        print("Login pressed")
        loginToUdacity(username: usernameTextField.text!, password: passwordTextField.text!) { (success, error, sessionID) in
            switch success {
                case true : print(sessionID)
                case false: print("False Returned: error : \(error)")
            }
        }
    }
    
    func loginToUdacity(username: String, password: String, completionHandlerForLogin : @escaping (_ success: Bool, _ error: Error? , _ sessionID : String?) -> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if let error = error { // Handle error…
                completionHandlerForLogin(false, error, nil)
            }
            
            let dataLength = data?.count
            let r = 5...Int(dataLength!)
            let newData = data?.subdata(in: Range(r)) /* subset response data! */
            var parsedResults: [String: AnyObject]
            
            do {
                parsedResults = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String: AnyObject]
                if let session = parsedResults["session"] as? [String: AnyObject], let id = session["id"] as? String {
                    completionHandlerForLogin(true, nil, id)
                }
                
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                completionHandlerForLogin(false, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo), nil)
            }
            
            
        }
        task.resume()
    }
    
    
}

