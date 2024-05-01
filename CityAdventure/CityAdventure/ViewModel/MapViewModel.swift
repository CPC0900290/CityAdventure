//
//  TaskBViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/17.
//

import Foundation
import UIKit
import MapKit

class MapViewModel {
  var locationManager: CLLocationManager?
  
  // MARK: - Function
  
  func checkLocationAuthorization(mapView: MKMapView) {
    guard let locationManager = locationManager,
          let location = locationManager.location else { return }
    
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
      mapView.setRegion(region, animated: true)
    case .denied:
      print("")
    case .restricted, .notDetermined:
      print("")
    @unknown default:
      print("")
    }
  }
  
  func setupLocationManager(_ viewController: CLLocationManagerDelegate) {
    locationManager = CLLocationManager()
    locationManager?.delegate = viewController
    locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager?.requestWhenInUseAuthorization()
    locationManager?.requestLocation()
  }
}
