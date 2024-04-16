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
  var locationManager: CLLocationManager?
  
  lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.showsUserLocation = true
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLocationManager()
    checkLocationAuthorization()
    setupUI()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
//    setPinUsingMKAnnotation(location: taskALocation)
    setPinUsingMKPlacemark(address: "100台北市中正區仁愛路二段99號")
  }
  
  private func setupUI() {
    view.addSubview(mapView)
    
    NSLayoutConstraint.activate([
      mapView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
      mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
      mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//      mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func setupLocationManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestWhenInUseAuthorization()
    locationManager?.requestLocation()
  }
  
  private func checkLocationAuthorization() {
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
  
  func setPinUsingMKPlacemark(address: String) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { placeMark, error in
      if let error = error {
        print(error.localizedDescription)
      } else {
        if let placemark = placeMark?.first?.location {
          let location = placemark.coordinate
          let pin = MapPin(title: "任務一", locationName: "任務地點", coordinate: location)
          let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
          self.mapView.setRegion(coordinateRegion, animated: true)
          self.mapView.addAnnotation(pin)
        }
      }
    }
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    checkLocationAuthorization()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
