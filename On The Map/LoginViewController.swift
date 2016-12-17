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

    var userKey = ""
    var firstName = ""
    var lastName = ""
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        subscribeToKeyboardNotifications()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        unSubscribeToKeyboardNotifications()
    }
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        showActivityIndicator()
        loginToUdacity(username: usernameTextField.text!, password: passwordTextField.text!) { (success, error, sessionID) in
            switch success {
            case true : performUIUpdatesOnMain {
                            self.performSegue(withIdentifier: "performLoginSegue", sender: nil)
                            self.hideActivityIndicator()
                        }
            
            case false: print("False Returned: error : \(error))")
                        performUIUpdatesOnMain {
                            self.hideActivityIndicator()
                        }
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
            if let error = error {
                completionHandlerForLogin(false, error, nil)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode > 399 && httpResponse.statusCode < 600 {
                    print("error \(httpResponse.statusCode)")
                    completionHandlerForLogin(false, NSError(domain: "returned code \(httpResponse.statusCode)", code: 1, userInfo: nil), nil)
                }
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
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unSubscribeToKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if view.frame.origin.y == 0{
                self.view.frame.origin.y -= 3.2 * passwordTextField.frame.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func showActivityIndicator() {
        indicator.color = UIColor.white
        indicator.backgroundColor = UIColor.darkGray
        indicator.alpha = 0.5
        indicator.frame = CGRect.init(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.layer.cornerRadius = 5
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.bringSubview(toFront: self.view)
        indicator.startAnimating()
    }
    
    func hideActivityIndicator(){
        indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
    }
}

