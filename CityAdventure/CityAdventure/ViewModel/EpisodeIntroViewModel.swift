//
//  EpisodeIntroViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/28.
//

import Foundation
import MapKit

protocol EpisodeDetailModelProtocol: AnyObject {
  func updatedDataModels()
}

class EpisodeIntroViewModel {
  var locationManager = CLLocationManager()
  var mapView: MKMapView?
  
  weak var delegate: EpisodeDetailModelProtocol?
  
  private var userDefault = UserDefaults()
  private var user: Profile?
  var episode: Episode?
  var tasks: [TaskLocations]? {
    didSet {
      fetchAnnotationsAndCoordinate()
      fetchProfile()
    }
  }
  
  var taskAnnotations: [CustomAnnotation] = []
  
  var taskCoordinates: [CLLocationCoordinate2D] = []
  
  // get episode from HomeVC when init
  init(episode: Episode? = nil) {
    self.episode = episode
    decodeTaskLocations()
  }
  
  // MARK: - EpisodeDetailVC
  // Decode TaskLocations in Episode
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
}
