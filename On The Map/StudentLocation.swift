//
//  StudentLocation.swift
//  On The Map
//
//  Created by Ajay Mann on 16/10/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import Foundation

class StudentLocation {
    var objectID : String
    var uniqueKey : String
    var firstName : String
    var lastName : String
    var mapString : String
    var mediaURL : String
    var latitude : Float
    var longitude : Float
    
    init(objectID : String, uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL : String, latitude: Float, longitude: Float) {
        self.objectID = objectID
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
}

