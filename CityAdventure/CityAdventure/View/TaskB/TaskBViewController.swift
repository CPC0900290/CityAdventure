//
//  TaskBViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/16.
//

import Foundation
import UIKit
import MapKit

class TaskBViewController: MapViewController {
  var currentPlacemark: CLPlacemark?
  //  let startingLocation = CLLocation(latitude: 25.03850, longitude: -121.53252)
  /* 北25.03832° 東121.53189°
   北25.03899° 東121.53225°
   北25.03897° 東121.53264°
   北25.03832° 東121.53261°*/
  var allLocations: [CLLocation] = []
  let taskRoute: [MKPlacemark] = [
    MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 25.03832, longitude: 121.53225)),
    MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 25.03899, longitude: 121.53189)),
    MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 25.03897, longitude: 121.53264)),
    MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 25.03832, longitude: 121.53261))
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLocationManager()
    setupUI()
  }
  
  // MARK: - UI Setup
  lazy var taskContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var taskView: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
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
  
  // MARK: - Function
  @objc func lastPage() {
    self.navigationController?.popViewController(animated: true)
  }
  
  func setupNavItem() {
    let navBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(lastPage))
    navBarItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = navBarItem
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
  
  private func setPinUsingMKAnnotation(location: CLLocationCoordinate2D) {
    let pin1 = MapPin(title: "任務一", locationName: "任務地點", coordinate: location)
    let coordinateRegion = MKCoordinateRegion(center: pin1.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
    mapView.setRegion(coordinateRegion, animated: true)
    mapView.addAnnotations([pin1])
  }
  
//  func drawingRoute() {
//    guard let currentPlacemark = currentPlacemark else { return }
//
//    let directionRequest = MKDirections.Request()
//
//    // 設定路徑起始與目的地
//    directionRequest.source = MKMapItem.forCurrentLocation()
//    let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
//    directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
//    directionRequest.transportType = MKDirectionsTransportType.automobile
//
//    // 方位計算
//    let directions = MKDirections(request: directionRequest)
//
//    directions.calculate { (routeResponse, routeError) -> Void in
//
//      guard let routeResponse = routeResponse else {
//        if let routeError = routeError {
//          print("Error: \(routeError)")
//        }
//        return
//      }
//
//      let route = routeResponse.routes[0]
//      self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
//
//    }
//  }
  
  override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let currentLocation = locations.first(where: { $0.horizontalAccuracy >= 0 }) else {
      return
    }
    
    let previousCoordinate = allLocations.last?.coordinate
    allLocations.append(currentLocation)
    
    if previousCoordinate == nil { return }
    
    var area = [previousCoordinate!, currentLocation.coordinate]
    let polyline = MKPolyline(coordinates: &area, count: area.count)
    mapView.addOverlay(polyline)
  }
}
