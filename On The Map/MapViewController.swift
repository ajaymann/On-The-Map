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
    var studentLocations = [StudentLocation]()
    
    @IBOutlet weak var studentLocationsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentLocationsMapView.delegate = self
        //getMyData(uniqueKey: self.appDelegate.uniqueKey!)
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
                return
            }
            var parsedResults: [String : AnyObject]
            do {
                parsedResults = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                
                if let newData = parsedResults["results"] as? [[String: AnyObject]] {
                    var count = 0
                    for dictionary in newData {
                        
                        guard let lat = dictionary["latitude"], let long = dictionary["longitude"], let first = dictionary["firstName"], let last = dictionary["lastName"], let mapString = dictionary["mapString"], let mediaURL = dictionary["mediaURL"]  , let uniqueKey = dictionary["uniqueKey"], let objectID = dictionary["objectId"]  else {
                                count += 1
                                print("Some problem \(count) ")
                                continue
                        }
                        
                        let location : StudentLocation = StudentLocation(objectID: objectID as! String, uniqueKey: uniqueKey as! String, firstName: first as! String, lastName: last as! String, mapString: mapString as! String, mediaURL: mediaURL as! String, latitude: Float(CLLocationDegrees(lat as! Double)), longitude: Float(long as! NSNumber))
                            self.studentLocations.append(location)
                            studentLocationListView.append(location)
                    }
                    self.showStudentPins()
                }
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
            
            for student in self.studentLocations {
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
        let urlString = "https://www.udacity.com/api/users/\(uniqueKey)"
        
        let url = URL(string: urlString)
        let urlComponent = url?.absoluteString
        
        var request = NSMutableURLRequest(url: URL(string:urlComponent!)!)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil { // Handle error
                return
            }
            
            let dataLength = data?.count
            let r = 5...Int(dataLength!)
            let newData = data?.subdata(in: Range(r)) /* subset response data! */
            
            var parsedResults: [String: AnyObject]
            
            do {
                parsedResults = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String: AnyObject]
                if let user = parsedResults["user"] as? [String: AnyObject], let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String {
                    self.appDelegate.firstName = firstName
                    self.appDelegate.lastName = lastName
                }
                
            } catch {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
              }
        }
        
        task.resume()
        
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
    
    class func sharedInstance() -> MapViewController {
        
        struct Singleton {
            static var sharedInstance = MapViewController()
        }
        return Singleton.sharedInstance
    }
}
