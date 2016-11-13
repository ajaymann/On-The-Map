//
//  LoginViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 16/10/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

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
            case true : print(self.appDelegate.uniqueKey!)
                        self.getMyData(uniqueKey: self.appDelegate.uniqueKey!)
                        performUIUpdatesOnMain {
                        self.performSegue(withIdentifier: "performLoginSegue", sender: nil)
                        }
            
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
                if let session = parsedResults["session"] as? [String: AnyObject], let id = session["id"] as? String, let account = parsedResults["account"] as? [String: AnyObject] {
                    self.appDelegate.uniqueKey = account["key"] as? String
                    completionHandlerForLogin(true, nil, id)
                }
                
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                completionHandlerForLogin(false, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo), nil)
            }
            
            
        }
        task.resume()
    }
    
    func getMyData(uniqueKey: String) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                return
            }
            
            var parsedResults: [String: AnyObject]
            
            do {
                parsedResults = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                if let result = parsedResults["results"] as? [String: AnyObject], let firstName = result["firstName"] as? String, let lastName = parsedResults["lastName"] as? String {
                    self.appDelegate.firstName = firstName
                    self.appDelegate.lastName = lastName
                }
                
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            }
            
        }
        task.resume()
    }
    
}

