//
//  SubmitLocationViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 03/11/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit
import MapKit

class SubmitLocationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mediaURLLink: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var locationText: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let locationText = locationText {
            self.showActivityIndicator()
            showLocationOnMap(locationText: locationText)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func submitPressed(_ sender: Any) {
        showActivityIndicator()
        if Reachability.isConnectedToNetwork() {
            mediaURL = mediaURLLink.text!
            let httpBody = "{\"uniqueKey\": \"\(userKey)\", \"firstName\": \"\(userFirstName)\", \"lastName\": \"\(userLastName)\",\"mapString\": \"\(locationText!)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
            ParseClient.sharedInstance().taskForPost(url: "https://parse.udacity.com/parse/classes/StudentLocation", jsonBody: httpBody, method: "POST", completionHandlerForPost: { (success, result, error) in
                if success == true {
                    performUIUpdatesOnMain {
                        let alert = UIAlertController(title: "Post Successful", message: "Pin has been posted", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { action in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        self.hideActivityIndicator()
                    }
                } else {
                    performUIUpdatesOnMain {
                        self.hideActivityIndicator()
                        let alert = UIAlertController(title: "Could Not Post", message: "Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
            })
        } else {
            hideActivityIndicator()
        }
    }
}

extension SubmitLocationViewController: MKMapViewDelegate {
    func showLocationOnMap(locationText: String){
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationText
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                self.hideActivityIndicator()
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: {action in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = locationText
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            latitude = pointAnnotation.coordinate.latitude
            longitude = pointAnnotation.coordinate.longitude
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = pointAnnotation.coordinate
            performUIUpdatesOnMain {
                self.hideActivityIndicator()
                self.mapView.addAnnotation(pinAnnotationView.annotation!)
            }
            
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
