//
//  HomeViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/23.
//

import Foundation
import Firebase
import FirebaseAuth

protocol HomeVMDelegate: AnyObject {
  func profileUpdated()
}

class HomeViewModel {
  weak var delegate: HomeVMDelegate?
  private let userDefault = UserDefaults()
  var totalEpisodes: [Episode] = []
  var areaEpisodes: [Episode] = []
  var adventuringEpisodes: [Episode] = [] {
    didSet {
      delegate?.profileUpdated()
    }
  }
  var profile: Profile?
  // Fetch all Episode from Firebase
  func fetchTotalEpisodes() {
    FireStoreManager.shared.fetchCollectionQuery(collectionName: "EpisodeList") {[weak self] query in
      do {
        let results = try query.documents.map { snapshot in
          let episode = try snapshot.data(as: Episode.self)
          return episode
        }
        self?.totalEpisodes = results
      } catch {
        print("HomeVM.fetchTotalEpisode fail to decode snapshots: \(error)")
      }
    }
  }
  
  // Fetch Area Episode from Firebase
  func fetchAreaEpisode(areaName: String) {
    FireStoreManager.shared.fetchFilteredSnapshots(collection: "EpisodeList", 
                                                   field: "area",
                                                   with: areaName) {[weak self] query in
      do {
        let results = try query.documents.map { snapshot in
          return try snapshot.data(as: Episode.self)
        }
        self?.areaEpisodes = results
      } catch {
        print("HomeVM.fetchAreaEpisode fail to decode snapshots: \(error)")
      }
    }
  }
  
  // Fetch Adventuring Episode from Firebase
  func fetchAdventuringEpisodes(completion: @escaping () -> Void) {
    guard let profile = profile else { return }
    let episodeIDList = profile.adventuringEpisode.map { $0.episodeID }
    guard !episodeIDList.isEmpty else { return }
    FireStoreManager.shared.fetchFilteredArrayQuery(collection: "EpisodeList",
                                                    field: "id",
                                                    with: episodeIDList) {[weak self] query in
      
      do {
        let results = try query.documents.map { snapshot in
          return try snapshot.data(as: Episode.self)
        }
        self?.adventuringEpisodes = results
        completion()
      } catch {
        print("HomeVM.fetchAdventuringEpisodes fail to decode snapshots: \(error)")
      }
    }
  }
  
  // Fetch Profile from Firebase
  func fetchProfile(completion: @escaping () -> Void) {
    guard let userID = userDefault.value(forKey: "uid") as? String else { return }
    FireStoreManager.shared.filterDocument(collection: "Profile", field: "userID", with: userID) {[weak self] document in
      do {
        let data = try document.data(as: Profile.self)
        self?.profile = data
        completion()
      } catch {
        print("fetchProfile fail to decode from doc: \(error)")
      }
    }
  }
}
