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
  func setPinUsingMKAnnotation(mapView: MKMapView ,location: CLLocationCoordinate2D) {
    let pin1 = MapPin(title: "任務一", locationName: "任務地點", coordinate: location)
    let coordinateRegion = MKCoordinateRegion(center: pin1.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
    mapView.setRegion(coordinateRegion, animated: true)
    mapView.addAnnotations([pin1])
  }
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
    locationManager?.requestWhenInUseAuthorization()
    locationManager?.requestLocation()
  }
}
