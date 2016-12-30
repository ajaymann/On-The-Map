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
        if Reachability.isConnectedToNetwork() == true
        {
            showActivityIndicator()
            let url = "https://www.udacity.com/api/session"
            UdacityClient.sharedInstance().taskForPost(url: url, jsonBody: "{\"udacity\": {\"username\": \"\(usernameTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}", method: "POST" , completionHandlerForPost: { (success, result, error) in
                
                switch success {
                case true :
                    if let account = result?["account"] as? [String: AnyObject], let key = account["key"]{
                        userKey = key as! String
                    }
                    performUIUpdatesOnMain {
                    self.performSegue(withIdentifier: "performLoginSegue", sender: nil)
                    self.hideActivityIndicator()
                    }
                    
                case false: performUIUpdatesOnMain {
                    self.hideActivityIndicator()
                    let alert = UIAlertController(title: "Error", message: "Username and Password not correct", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
        else {
            let alert = UIAlertController(title: "No Internet", message: "No Internet Connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }

}

