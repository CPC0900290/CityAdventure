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
  func fetchLocation(task: TestTask, sendLocation: @escaping ([MKGeoJSONFeature]) -> Void) {
    let location = task.locationAddress
    guard let data = location.data(using: .utf8) else { return }
    do {
      if let features = try MKGeoJSONDecoder().decode(data) as? [MKGeoJSONFeature] {
        for feature in features {
          if let data = feature.properties,
             let taskLocationDetail = try? JSONDecoder().decode(LocationDetail.self, from: data) {
            print(taskLocationDetail, feature.geometry[0].coordinate)
          }
        }
      }
    } catch {
      fatalError("Fail to decode data from location: \(error)")
    }
  }
  
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
    locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager?.requestWhenInUseAuthorization()
    locationManager?.requestLocation()
  }
}
