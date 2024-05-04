//
//  HomeViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/23.
//

import Foundation
import FirebaseAuth

protocol HomeVMDelegate: AnyObject {
  func profileUpdated()
}

class HomeViewModel {
  weak var delegate: HomeVMDelegate?
  private let userDefault = UserDefaults()
  var idList: [String] = []
  var episodeList: [Episode] = []
  var areaEpisodes: [Episode] = []
  
  var profile: Profile? {
    didSet {
      delegate?.profileUpdated()
    }
  }
  
  func fetchEpisode(id: String, sendEpisode: @escaping (Episode) -> Void) {
    FireStoreManager.shared.fetchDocument(collection: "EpisodeList", id: id) { snapshot in
      do {
        let episode = try snapshot.data(as: Episode.self)
        sendEpisode(episode)
      } catch let error {
        print("Fail to decode Episode: \(error)")
      }
    }
  }
  
  func fetchAreaEpisode(areaName: String, sendAreaEpisode: @escaping ([String]) -> Void) {
    FireStoreManager.shared.fetchFilteredDoc(collection: "EpisodeList", field: "Area", with: areaName) { docIDList in
      sendAreaEpisode(docIDList)
      for id in docIDList {
        FireStoreManager.shared.fetchDocument(collection: "EpisodeList", id: id) { documentSnapshot in
          do {
            let data = try documentSnapshot.data(as: Episode.self)
            self.areaEpisodes.append(data)
          } catch {
            print("fail to decode area episode")
          }
        }
      }
    }
  }
  
  func fetchEpisodeList(sendEpisodeIDList: @escaping ([String]) -> Void) {
    FireStoreManager.shared.fetchCollection(collectionName: "EpisodeList") { episodeIDList in
      self.idList = episodeIDList
      sendEpisodeIDList(episodeIDList)
    }
  }
  
  func fetchProfile(uid: String, sendProfile: @escaping (Profile) -> Void) {
    FireStoreManager.shared.filterDocument(collection: "Profile", field: "userID", with: uid) { document in
      do {
        let data = try document.data(as: Profile.self)
        sendProfile(data)
        self.profile = data
      } catch {
        print("fetchProfile fail to decode from doc: \(error)")
      }
    }
  }
  
//  func fetchAdventuringEpisodes(send: @escaping ([Episode]) -> Void) {
//    guard let profile = profile else { return }
//    let adventuringEpisodeIDList = profile.adventuringEpisode.map { $0.episodeID }
//    adventuringEpisodeIDList.forEach { episodeID in
//      let query = FireStoreManager.shared.firestore.collection("EpisodeList").whereField("id", isEqualTo: adventuringEpisodeIDList)
//      query.getDocuments { snapshots, error in
//        if let error = error {
//          print("HomeVM.fetchAdventuringEpisodes fail to filter snapshot: \(error)")
//        }
//        guard let snapshots = snapshots else { return }
//        var adventuringEpisodeList: [Episode] = []
//        snapshots.documents.forEach { snapshot in
//          do {
//            let data = try snapshot.data(as: Episode.self)
//            adventuringEpisodeList.append(data)
//          } catch {
//            print("HomeVM.fetchAdventuringEpisodes fail to decode data: \(error)")
//          }
//        }
//        send(adventuringEpisodeList)
//      }
//    }
//    
//  }
}
