//
//  SecondTaskViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/20.
//

import Foundation
import MapKit

class SecondTaskViewModel: NSObject {
  // MARK: - Properties var
  var locationManager: CLLocationManager?
  var episode: Episode?
  var secondTask: TaskLocations?
  /// A custom `MKOverlay` that contains the path a user travels.
  var breadcrumbs: BreadcrumbPath?
  var breadcrumbPathRenderer: BreadcrumbPathRenderer?
  var taskRouteOverlay: MKOverlay?
  private var userLocations: [CLLocation] = []
  var allLocations: [CLLocation] = [] {
    didSet {
      setupTaskRouteOverlay()
    }
  }
  private var arrivedTaskCount = 0
  private var isFinishedRoute = false
  
  init(episode: Episode, secondTask: TaskLocations?) {
    self.episode = episode
    self.secondTask = secondTask
//    self.locationManager = locationManger
    super.init()
    self.fetchLocation()
  }
  
  // MARK: - Functions
  func detectTaskFinishedStatus(from viewController: UIViewController) {
    if isFinishedRoute {
      stopRecordUserLocation()
      let successVC = SuccessViewController()
      successVC.modalPresentationStyle = .fullScreen
      successVC.episodeID = episode?.id
      successVC.taskNum = 1
      viewController.present(successVC, animated: true)
    }
  }
  
  func configUserLocationToTaskLocations(with currentLocation: CLLocation) {
    for location in allLocations {
      let distance = currentLocation.distance(from: location)
      if distance < 20 { // 持續追蹤看是否會因為設定的距離太短，導致很容易因為定位精準度不夠而沒有計算到
        configIsFinishedRoute()
      }
    }
  }
  
  private func configIsFinishedRoute() {
    arrivedTaskCount += 1
    if !allLocations.isEmpty {
      isFinishedRoute = Float(arrivedTaskCount) > (Float(allLocations.count) / 1.5)
    }
  }
  
  func setupTaskRouteOverlay() {
    if allLocations.isEmpty {
      print("==== No Coordinates to draw")
      return
    }
    
    let coordinates = allLocations.map { location -> CLLocationCoordinate2D in
      return location.coordinate
    }
    
    taskRouteOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
  }
  
  func stopRecordUserLocation() {
    guard let locationManager = locationManager else {
      print("SecondTaskViewModel.setupLocationManager accidentily got nil")
      return
    }
    
    locationManager.stopUpdatingLocation()
    locationManager.stopUpdatingHeading()
  }
  
  func setupLocationManager() {
    guard let locationManager = locationManager else {
      print("SecondTaskViewModel.setupLocationManager accidentily got nil")
      return
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
  }
  
  private func fetchLocation() {
    guard let secondTask = secondTask,
          let points = secondTask.features[1].geometry.coordinates
    else { return }
    for point in points {
      let location = CLLocation(latitude: point[0], longitude: point[1])
      allLocations.append(location)
    }
  }
  
  func getUserLocation(from mapView: MKMapView) {
    if let breadcrumbs {
      mapView.removeOverlay(breadcrumbs)
      breadcrumbPathRenderer = nil
    }
    
    // Create a fresh path when starting to record the locations.
    breadcrumbs = BreadcrumbPath()
    guard let breadcrumbs = breadcrumbs else { return }
    mapView.addOverlay(breadcrumbs, level: .aboveRoads)
  }
}
