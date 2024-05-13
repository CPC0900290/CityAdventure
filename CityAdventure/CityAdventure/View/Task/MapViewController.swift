//
//  MapViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/13.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
  var tasks: [Properties] = []
  var locationManager: CLLocationManager?
  var mapViewModel = MapViewModel()
  
  lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.showsUserLocation = true
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapViewModel.setupLocationManager(self)
    mapViewModel.checkLocationAuthorization(mapView: mapView)
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    mapViewModel.checkLocationAuthorization(mapView: mapView)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
