//
//  MapViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 21/10/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {

    var studentLocations = [StudentLocation]()
    var annotations = [MKPointAnnotation]()

  
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        showStudentPins()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        showStudentPins()
//    }
    
    @IBOutlet weak var studentLocationsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentLocationsMapView.delegate = self
        getStudentLocations()
    }

    func getStudentLocations() {
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            var parsedResults: [String : AnyObject]
            do {
                parsedResults = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                if let newData = parsedResults["results"] as? [[String: AnyObject]] {
                    for dictionary in newData {
                        let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
                        let long = CLLocationDegrees(dictionary["longitude"] as! Double)
                        let first = dictionary["firstName"] as! String
                        let last = dictionary["lastName"] as! String
                        let mediaURL = dictionary["mediaURL"] as! String
                        let mapString = dictionary["mapString"] as! String
                        let uniqueKey = dictionary["uniqueKey"] as! String
                        let objectID = dictionary["objectId"] as! String
                        let location : StudentLocation = StudentLocation(objectID: objectID, uniqueKey: uniqueKey, firstName: first, lastName: last, mapString: mapString, mediaURL: mediaURL, latitude: Float(lat), longitude: Float(long))
                        self.studentLocations.append(location)
                    }
                    self.showStudentPins()
                }
            }
            catch {
                _ = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            }
        }
        task.resume()
    }
    
    func showStudentPins() {
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
    
    private func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    private func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)! as URL)
            }
        }
    }


}
