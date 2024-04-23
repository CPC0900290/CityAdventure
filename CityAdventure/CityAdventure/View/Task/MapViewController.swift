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
    setupUI()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    print(tasks)
    let firstTaskAddress = tasks[0].locationAddress
    let secondTaskAddress = tasks[1].locationAddress
    let thirdTaskAddress = tasks[2].locationAddress
    setPinUsingMKPlacemark(address: firstTaskAddress, title: "任務一")
    setPinUsingMKPlacemark(address: secondTaskAddress, title: "任務二")
    setPinUsingMKPlacemark(address: thirdTaskAddress, title: "任務三")
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
  
  func setPinUsingMKPlacemark(address: String, title: String) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { placeMark, error in
      if let error = error {
        print(error.localizedDescription)
      } else {
        if let placemark = placeMark?.first?.location {
          let location = placemark.coordinate
          let pin = MapPin(title: title, locationName: "任務地點", coordinate: location)
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
    mapViewModel.checkLocationAuthorization(mapView: mapView)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
