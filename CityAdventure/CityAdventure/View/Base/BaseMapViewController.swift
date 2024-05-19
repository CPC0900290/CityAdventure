//
//  BaseMapViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/17.
//

import Foundation
import UIKit
import MapKit

class BaseMapViewController: UIViewController {
  // MARK: - Property var
  lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.showsUserLocation = true
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  var locationManager = CLLocationManager()
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLocationManager()
    setupMapView()
  }
  
  // 檢查位置授權
  func checkLocationAuthorization(mapView: MKMapView) {
    guard let _ = locationManager.location else {
      print("User location is not empty, so we don't check authorization again")
      return
    }
    
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      print("Location access authorized")
    case .denied:
      print("Location access denied")
    case .restricted, .notDetermined:
      print("Location access restricted or not determined")
    @unknown default:
      print("Unknown location authorization status")
    }
  }
}

extension BaseMapViewController: MKMapViewDelegate {
  func setupMapView() {
    mapView.delegate = self
    mapView.showsUserLocation = true
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard !annotation.isKind(of: MKUserLocation.self) else {
      return nil
    }
    
    var annotationView: MKAnnotationView?
    
    if let annotation = annotation as? CustomAnnotation {
      annotationView = setupCustomAnnotationView(for: annotation, on: mapView)
    }
    
    return annotationView
  }
  
  private func setupCustomAnnotationView(for annotation: CustomAnnotation, on mapView: MKMapView) -> MKAnnotationView {
    let identifier = NSStringFromClass(CustomAnnotation.self)
    let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
    if let markerAnnotationView = view as? MKMarkerAnnotationView {
      markerAnnotationView.animatesWhenAdded = true
      markerAnnotationView.canShowCallout = true
      markerAnnotationView.markerTintColor = UIColor(hex: "E7F161", alpha: 1)
    }
    return view
  }
}

extension BaseMapViewController: CLLocationManagerDelegate {
  func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
