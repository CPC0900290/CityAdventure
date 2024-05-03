//
//  EpisodeDetailViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/28.
//

import Foundation
import MapKit

protocol EpisodeDetailModelProtocol: AnyObject {
  func updatedDataModels()
}

class EpisodeDetailViewModel {
  var locationManager: CLLocationManager?
  private var delegate: EpisodeDetailModelProtocol?
  private var userDefault: UserDefaults?
  
  private var episode: Episode?
  var tasks: [TaskLocations]? {
    didSet {
      fetchAnnotationsAndCoordinate()
    }
  }
  
  var taskAnnotations: [CustomAnnotation] = []
  
  var taskCoordinates: [CLLocationCoordinate2D] = []
  
  func checkLocationAuthorization(mapView: MKMapView) {
    guard let locationManager = locationManager,
          let _ = locationManager.location else { return }
    
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
  // MARK: - New
  func setupLocationManager(_ viewController: CLLocationManagerDelegate) {
    locationManager = CLLocationManager()
    locationManager?.delegate = viewController
    locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager?.requestWhenInUseAuthorization()
    locationManager?.requestLocation()
  }
  
  func getData(episode: Episode) {
    self.episode = episode
    var temp: [TaskLocations] = []
    for task in episode.tasks {
      guard let data = task.data(using: .utf8) else { return }
      do {
        let taskLocation = try JSONDecoder().decode(TaskLocations.self , from: data)
        temp.append(taskLocation)
      } catch let error {
        print("fail to decode data from task: \(error)")
      }
    }
    tasks = temp
  }
  
  func fetchAnnotationsAndCoordinate() {
    guard let tasks = tasks else { return }
    for taskLocation in tasks {
      let locationPath = taskLocation.features
      guard let location = locationPath.first,
            let points = location.geometry.coordinate
      else { return }
      let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(points[0]),
                                              longitude: CLLocationDegrees(points[1]))
      let annotation = CustomAnnotation(coordinate: coordinate)
      annotation.title = locationPath.first?.properties.title
      annotation.subtitle = locationPath.first?.properties.locationName
      self.taskAnnotations.append(annotation)
      self.taskCoordinates.append(coordinate)
    }
  }
  
  func updateUserPlayingList(_ adventuringEpisode: AdventuringEpisode) {
    guard let profile = userDefault?.value(forKey: "uid") as? Profile else { return }
    FireStoreManager.shared.getDocumentReference(collection: "Profile", id: profile.documentID) { ref in
      ref.getDocument { snapshot, error in
        if let error = error {
          print("EpisodeDetailViewModel fail to get document: \(error)")
          return
        }
        guard let snapshot = snapshot else { return }
        do {
          var data = try snapshot.data(as: Profile.self)
          let episodeIDList = data.adventuringEpisode.map { $0.episodeID }
          if !episodeIDList.contains(adventuringEpisode.episodeID) {
            data.adventuringEpisode.append(adventuringEpisode)
            try ref.setData(from: data, mergeFields: ["adventuringEpisode"])
          }
        } catch {
          print("EpisodeDetailViewModel fail to decode data: \(error)")
        }
      }
    }
  }
}
