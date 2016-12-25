//
//  MapViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 21/10/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var studentLocationsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentLocationsMapView.delegate = self
        getMyData(uniqueKey: userKey)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        studentLocations.removeAll()
        getStudentLocations()
    }
    
    func getStudentLocations() {
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                let alert = UIAlertController(title: "Error", message: "Download Failed", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode > 399 && httpResponse.statusCode < 600 {
                    print("error \(httpResponse.statusCode)")
                    let alert = UIAlertController(title: "Error", message: "Download Failed", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            var parsedResults: [String : AnyObject]
            do {
                parsedResults = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                guard let newData = parsedResults["results"] as? [[String: AnyObject]] else {
                    return
                }
                for dictionary in newData {
                    if let location : StudentLocation = StudentLocation(dict: dictionary){
                        studentLocations.append(location)
                    }
                }
                self.showStudentPins()
            }
            catch {
                _ = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            }
        }
        task.resume()
        
        // This is to remove previous location pins and to add new pins if they were added while the user was posting his own pin.
        if let annotations = studentLocationsMapView.annotations as? [MKPointAnnotation] {
            studentLocationsMapView.removeAnnotations(annotations)
            self.annotations.removeAll()
        }
    }
    
    func showStudentPins() {
        if !studentLocations.isEmpty {
            
            for student in studentLocations {
                let lat = student.latitude
                let lon =  student.longitude
                let firstName = student.firstName
                let lastName = student.lastName
                let mediaURL = student.mediaURL
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                self.annotations.append(annotation)
            }
            performUIUpdatesOnMain {
                self.studentLocationsMapView.addAnnotations(self.annotations)
            }
            
        }
    }
    
    func getMyData(uniqueKey: String) {
        UdacityClient.sharedInstance().taskForPost(url: "https://www.udacity.com/api/users/\(uniqueKey)", jsonBody: nil, method : "GET") { (success, result, error) in
           
                if let user = result?["user"] as? [String: AnyObject], let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String {
                    userFirstName = firstName
                    userLastName = lastName
                }
        }
    }
    
    @IBAction func myUnwindAction(segue: UIStoryboardSegue) {}

}


extension MapViewController: MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            let reuserIdentifier = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuserIdentifier) as? MKPinAnnotationView
            
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuserIdentifier)
                pinView!.canShowCallout = true
                pinView!.pinTintColor = .red
                pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                pinView?.annotation = annotation
            }
            
            return pinView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            if let url = URL(string: (view.annotation?.subtitle!)!) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
        }
    
}
