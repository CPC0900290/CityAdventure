//
//  CustomAnnotations.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/28.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
  
  // This property must be key-value observable, which the `@objc dynamic` attributes provide.
  @objc dynamic var coordinate: CLLocationCoordinate2D
  
  var title: String?
  
  var subtitle: String?
  
  var imageName: String?
  
  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    super.init()
  }
}
