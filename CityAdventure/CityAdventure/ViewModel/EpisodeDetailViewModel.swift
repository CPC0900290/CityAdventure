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
  weak var delegate: EpisodeDetailModelProtocol?
  private var userDefault = UserDefaults()
  
  private var user: Profile? 
  
  private var episode: Episode?
  var tasks: [TaskLocations]? {
    didSet {
      fetchAnnotationsAndCoordinate()
      fetchProfile()
      getDistance()
    }
  }
  
  var taskAnnotations: [CustomAnnotation] = []
  
  var taskCoordinates: [CLLocationCoordinate2D] = []
  
  var distanceToTask: [CLLocationDistance]?
  
  var taskStatus: [Bool]? {
    didSet {
      delegate?.updatedDataModels()
    }
  }
  
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
  // MARK: - EpisodeDetailVC
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
  
  func fetchProfile() {
    guard let userID = userDefault.value(forKey: "uid") as? String else { return }
    FireStoreManager.shared.filterDocument(collection: "Profile", field: "userID", with: userID) { snapshot in
      do {
        let profile = try snapshot.data(as: Profile.self)
        self.user = profile
      } catch {
        print("EpisdoeDetailViewModel fail to decode Profile: \(error)")
      }
    }
  }
  
  func updateUserPlayingList(_ adventuringEpisode: AdventuringEpisode) {
    guard let user = user else { return }
    FireStoreManager.shared.getDocumentReference(collection: "Profile", id: user.documentID) { ref in
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
  
  // MARK: - EpisodeVC
  func getDistanceToTask(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
    guard let userCoordinate = locationManager?.location else { return 0 }
    let distance = userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude,
                                                            longitude: coordinate.longitude))
 return distance
  }
  
  func getDistance() {
    guard let userCoordinate = locationManager?.location else { return }
    var distanceList: [CLLocationDistance] = []
    for coordinate in taskCoordinates {
      let distance = userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude,
                                                              longitude: coordinate.longitude))
      distanceList.append(distance)
    }
    self.distanceToTask = distanceList
  }
  
  func configureTaskStatus() {
    guard let userID = userDefault.value(forKey: "uid") as? String,
          let episode = episode
    else { return }
    FireStoreManager.shared.filterDocument(collection: "Profile", field: "userID", with: userID) { snapshot in
      do {
        let localAdventuringEpisode = episode.id
        let profile = try snapshot.data(as: Profile.self)
        profile.adventuringEpisode.forEach { adventuringEpisode in
          if adventuringEpisode.episodeID == localAdventuringEpisode {
            self.taskStatus = adventuringEpisode.taskStatus
          }
        }
      } catch {
        print("EpisdoeDetailViewModel fail to decode Profile: \(error)")
      }
    }
  }
}
