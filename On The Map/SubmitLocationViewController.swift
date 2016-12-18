//
//  SubmitLocationViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 03/11/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit
import MapKit

class SubmitLocationViewController: UIViewController {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mediaURLLink: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var locationText: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let locationText = locationText {
            showLocationOnMap(locationText: locationText)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        appDelegate.mediaURL = mediaURLLink.text
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")! as URL)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(appDelegate.uniqueKey!)\", \"firstName\": \"\(appDelegate.firstName!)\", \"lastName\": \"\(appDelegate.lastName!)\",\"mapString\": \"\(locationText!)\", \"mediaURL\": \"\(appDelegate.mediaURL!)\",\"latitude\": \(appDelegate.latitude!), \"longitude\": \(appDelegate.longitude!)}".data(using: String.Encoding.utf8)

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode > 199 && httpResponse.statusCode < 300 {
                    performUIUpdatesOnMain {
                        let alert = UIAlertController(title: "Post Successful", message: "Pin has been posted", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { action in
                            self.performSegue(withIdentifier: "unwind", sender: nil)

                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                    
                }
            }
            
            var parsedResults: [String: AnyObject]

            do {
                parsedResults = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                if let objectId = parsedResults["objectId"] as? String {
                    
                }
                
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            }
        }
        task.resume()
    }
}

extension SubmitLocationViewController: MKMapViewDelegate {
    func showLocationOnMap(locationText: String){
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationText
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = locationText
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            self.appDelegate.latitude = pointAnnotation.coordinate.latitude
            self.appDelegate.longitude = pointAnnotation.coordinate.longitude
            
            print("Latitude : \(self.appDelegate.latitude?.description)")
            print("Lon : \(self.appDelegate.longitude?.description)")
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = pointAnnotation.coordinate
            performUIUpdatesOnMain {
                self.mapView.addAnnotation(pinAnnotationView.annotation!)
            }
            
        }
    }
}
