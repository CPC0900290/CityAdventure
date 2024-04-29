//
//  MKCoordinateRegionExt.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/29.
//

import Foundation
import MapKit
extension MKCoordinateRegion {
  init(coordinates: [CLLocationCoordinate2D]) {
    var maxLat: CLLocationDegrees = -90.0
    var maxLong: CLLocationDegrees = -180.0
    var minLat: CLLocationDegrees = 90.0
    var minLong: CLLocationDegrees = 180.0
    
    for location in coordinates {
      minLat = min(minLat, location.latitude)
      minLong = min(minLong, location.longitude)
      maxLat = max(maxLat, location.latitude)
      maxLong = max(maxLong, location.longitude)
    }
    
    let center = CLLocationCoordinate2D(latitude: (maxLat + minLat) / 2.0, longitude: (maxLong + minLong) / 2.0)
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat), longitudeDelta: (maxLong - minLong))
    
    self.init(center: center, span: span)
  }
}
