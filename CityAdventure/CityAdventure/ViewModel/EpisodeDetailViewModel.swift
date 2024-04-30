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
  
  func checkLocationAuthorization(mapView: MKMapView) {
    guard let locationManager = locationManager,
          let location = locationManager.location else { return }
    
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      print("")
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
  
  func fetchTask(episode: Episode, sendTask: @escaping ([TaskLocations]) -> Void) {
    let tasks = episode.tasks
    var results: [TaskLocations] = []
    for task in tasks {
      guard let data = task.data(using: .utf8) else { return }
      do {
        let taskLocation = try JSONDecoder().decode(TaskLocations.self , from: data)
        results.append(taskLocation)
      } catch let error {
        print("fail to decode data from task: \(error)")
      }
    }
    sendTask(results)
  }
  
  func fetchCoordinate(taskLocations: [TaskLocations], sendLocation: @escaping ([CLLocationCoordinate2D]) -> Void) {
    var taskLocationList: [CLLocationCoordinate2D] = []
    for taskLocation in taskLocations {
      let locationPath = taskLocation.features
      guard let points = locationPath.first?.geometry.coordinate else { return }
      taskLocationList.append(CLLocationCoordinate2D(latitude: CLLocationDegrees(points[0]),
                                                     longitude: CLLocationDegrees(points[1])))
      
    }
    sendLocation(taskLocationList)
  }
  
  func fetchAnnotation(taskLocations: [TaskLocations], sendLocation: @escaping ([CustomAnnotation]) -> Void) {
    var taskLocationList: [CustomAnnotation] = []
    for taskLocation in taskLocations {
      let locationPath = taskLocation.features
      guard let location = locationPath.first,
            let points = location.geometry.coordinate
      else { return }
      let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(points[0]),
                                              longitude: CLLocationDegrees(points[1]))
      let annotation = CustomAnnotation(coordinate: coordinate)
      annotation.title = locationPath.first?.properties.title
      annotation.subtitle = locationPath.first?.properties.locationName
      taskLocationList.append(annotation)
    }
    sendLocation(taskLocationList)
  }
  
  func updateUserPlayingList(user: Profile,_ adventuringEpisode: AdventuringEpisode) {
    // Doing
    FireStoreManager.shared.updateUserProfile(userID: user.id, adventuringEpisode: adventuringEpisode)
  }
}
