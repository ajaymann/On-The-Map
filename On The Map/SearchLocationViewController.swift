//
//  SearchLocationViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 03/11/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit

class SearchLocationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var searchLoctation : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchButton.layer.cornerRadius = 5.0
        NotificationCenter.default.addObserver(self, selector: #selector(popVC), name: NSNotification.Name(rawValue: "popVC"), object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        subscribeToKeyboardNotifications()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        unSubscribeToKeyboardNotifications()
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
            self.view.frame.origin.y -= locationTextField.frame.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        searchLoctation = locationTextField.text!
        performSegue(withIdentifier: "SearchLocation", sender: nil)
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! SubmitLocationViewController
        destinationViewController.locationText = searchLoctation
        destinationViewController.show(self, sender: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
}
