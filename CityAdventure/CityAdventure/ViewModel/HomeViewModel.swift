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
  var idList: [String] = []
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
    FireStoreManager.shared.fetchCollectionQuery(collectionName: "EpisodeList") { query in
      do {
        let results = try query.documents.map { snapshot in
          let episode = try snapshot.data(as: Episode.self)
          return episode
        }
        self.totalEpisodes = results
      } catch {
        print("HomeVM.fetchTotalEpisode fail to decode snapshots: \(error)")
      }
    }
  }
  
  // Fetch Area Episode from Firebase
  func fetchAreaEpisode(areaName: String) {
    FireStoreManager.shared.fetchFilteredSnapshots(collection: "EpisodeList", 
                                                   field: "area",
                                                   with: areaName) { query in
      do {
        let results = try query.documents.map { snapshot in
          return try snapshot.data(as: Episode.self)
        }
        self.areaEpisodes = results
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
                                                    with: episodeIDList) { query in
      
      do {
        let results = try query.documents.map { snapshot in
          return try snapshot.data(as: Episode.self)
        }
        self.adventuringEpisodes = results
        completion()
        print(self.adventuringEpisodes)
      } catch {
        print("HomeVM.fetchAdventuringEpisodes fail to decode snapshots: \(error)")
      }
    }
  }
  
  // Fetch Profile from Firebase
  func fetchProfile(completion: @escaping () -> Void) {
    guard let userID = userDefault.value(forKey: "uid") as? String else { return }
    FireStoreManager.shared.filterDocument(collection: "Profile", field: "userID", with: userID) { document in
      do {
        let data = try document.data(as: Profile.self)
        self.profile = data
        completion()
      } catch {
        print("fetchProfile fail to decode from doc: \(error)")
      }
    }
  }
  
  func fetchEpisode(id: String, sendEpisode: @escaping (Episode) -> Void) {
    FireStoreManager.shared.fetchDocument(collection: "EpisodeList", id: id) { snapshot in
      do {
        let episode = try snapshot.data(as: Episode.self)
        self.totalEpisodes.append(episode)
        sendEpisode(episode)
      } catch let error {
        print("Fail to decode Episode: \(error)")
      }
    }
  }
  
  func fetchEpisodeList(sendEpisodeIDList: @escaping ([String]) -> Void) {
    FireStoreManager.shared.fetchCollection(collectionName: "EpisodeList") { episodeIDList in
      self.idList = episodeIDList
      sendEpisodeIDList(episodeIDList)
    }
  }
}
