//
//  LocationAnnotation.swift
//  assignment1
//
//  Created by Yujie Wu on 1/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import MapKit

class Sight: NSObject, MKAnnotation {
    var sight: SightEntity?
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var image: String?
    var icon: String?
    
    init(newSightName: String, newSightDesc: String, lat: Double, long: Double) {
        self.title = newSightName
        self.subtitle = newSightDesc
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    init(sight: SightEntity) {
        self.sight = sight
        self.title = sight.name
        self.subtitle = sight.desc
        self.image = sight.image
        self.icon = sight.icon
        
        let latitude = Double(sight.lat!)
        let longitude = Double(sight.long!)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
        
    }
}
