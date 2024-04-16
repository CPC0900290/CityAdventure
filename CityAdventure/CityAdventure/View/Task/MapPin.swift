//
//  MapPin.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/16.
//

import Foundation
import MapKit

class MapPin: NSObject, MKAnnotation {
  let title: String?
  let locationName: String
  let coordinate: CLLocationCoordinate2D
  init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.locationName = locationName
    self.coordinate = coordinate
  }
}
