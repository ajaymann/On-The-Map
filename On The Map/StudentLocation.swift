//
//  StudentLocation.swift
//  On The Map
//
//  Created by Ajay Mann on 16/10/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import Foundation

struct StudentLocation {
    var objectID : String
    var uniqueKey : String
    var firstName : String
    var lastName : String
    var mapString : String
    var mediaURL : String
    var latitude : Float
    var longitude : Float
    
    init?(dict: [String: AnyObject]){
        
        guard let objectID = dict["objectId"], let uniqueKey = dict["uniqueKey"], let firstName = dict["firstName"], let lastName =  dict["lastName"], let mapString = dict["mapString"], let mediaURL = dict["mediaURL"], let latitude = dict["latitude"], let longitude = dict["longitude"] else {
            return nil
        }
        
        self.objectID = objectID as! String
        self.uniqueKey = uniqueKey as! String
        self.firstName = firstName as! String
        self.lastName = lastName as! String
        self.mapString = mapString as! String
        self.mediaURL = mediaURL as! String
        self.latitude = latitude as! Float
        self.longitude = longitude as! Float
        
    }
    
}

