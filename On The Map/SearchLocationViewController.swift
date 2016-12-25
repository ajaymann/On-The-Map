//
//  SearchLocationViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 03/11/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit

class SearchLocationViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var searchLoctation : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchButton.layer.cornerRadius = 5.0
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        searchLoctation = locationTextField.text!
        performSegue(withIdentifier: "SearchLocation", sender: nil)
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! SubmitLocationViewController
        destinationViewController.locationText = searchLoctation
        destinationViewController.show(self, sender: nil)
    }
}
