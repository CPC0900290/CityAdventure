//
//  EpisodeDetailViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/28.
//

import Foundation
import MapKit

class EpisodeDetailViewModel {
  var locationManager: CLLocationManager?
  
  func setPinForTaskLocation(mapView: MKMapView,
                             location: CLLocationCoordinate2D,
                             title: String,
                             locationName: String) {
    let pin = MapPin(title: title, locationName: locationName, coordinate: location)
    let region = MKCoordinateRegion(center: pin.coordinate,
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500)
    mapView.setRegion(region, animated: true)
    mapView.addAnnotation(pin)
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
  
  func fetchTask(episode: Episode, sendTask: @escaping ([LocationPath]) -> Void) {
    let tasks = episode.tasks
    var results: [LocationPath] = []
    for task in tasks {
      guard let data = task.data(using: .utf8) else { return }
      do {
        let taskLocations = try JSONDecoder().decode(TaskLocations.self , from: data)
        let locationPaths = taskLocations.features
        results = locationPaths
      } catch let error {
        print("fail to decode data from task: \(error)")
      }
    }
    sendTask(results)
  }
  
  func fetchCoordinate(locationPaths: [LocationPath], sendLocation: @escaping ([CLLocationCoordinate2D]) -> Void) {
    var taskLocationList: [CLLocationCoordinate2D] = []
    for locationPath in locationPaths {
      guard let points = locationPath.geometry.coordinate else { return }
      taskLocationList.append(CLLocationCoordinate2D(latitude: CLLocationDegrees(points[0]),
                                                     longitude: CLLocationDegrees(points[1])))
    }
    sendLocation(taskLocationList)
  }
  
  func fetchAnnotation(locationPaths: [LocationPath], sendLocation: @escaping ([CustomAnnotation]) -> Void) {
    var taskLocationList: [CustomAnnotation] = []
    for locationPath in locationPaths {
      guard let points = locationPath.geometry.coordinate else { return }
      let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(points[0]),
                                              longitude: CLLocationDegrees(points[1]))
      let annotation = CustomAnnotation(coordinate: coordinate)
      annotation.title = locationPath.properties.title
      annotation.subtitle = locationPath.properties.locationName
      taskLocationList.append(annotation)
    }
    sendLocation(taskLocationList)
  }
}
