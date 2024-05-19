//
//  EpisodeViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/17.
//

import Foundation
import MapKit

protocol EpisodeModelProtocol: AnyObject {
  func updatedDataModels()
}

class EpisodeViewModel {
  var locationManager = CLLocationManager()
  weak var delegate: EpisodeModelProtocol?
  private var userDefault = UserDefaults()
  
  var episode: Episode?
  
  private var user: Profile?
  
  var tasks: [TaskLocations]? {
    didSet {
      fetchAnnotationsAndCoordinate()
      fetchProfile()
      getDistance()
    }
  }
  
  var taskStatus: [Bool]? {
    didSet {
      delegate?.updatedDataModels()
    }
  }
  
  var taskAnnotations: [CustomAnnotation] = []
  
  var taskCoordinates: [CLLocationCoordinate2D] = []
  
  var distanceToTask: [CLLocationDistance]?
  
  var secondTaskCoordinates: [CLLocationCoordinate2D] = []
  
  init(episode: Episode? = nil) {
    self.episode = episode
    decodeTaskLocations()
  }
  
  // MARK: - Function
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
  
  private func decodeTaskLocations() {
    guard let episode = episode else { return }
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
  
  func getDistanceToTask(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
    guard let userCoordinate = locationManager.location else { return 0 }
    let distance = userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude,
                                                            longitude: coordinate.longitude))
    return distance
  }
  
  func getDistance() {
    guard let userCoordinate = locationManager.location else { return }
    var distanceList: [CLLocationDistance] = []
    for annotation in taskAnnotations {
      let distance = userCoordinate.distance(from: CLLocation(latitude: annotation.coordinate.latitude,
                                                              longitude: annotation.coordinate.longitude))
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
