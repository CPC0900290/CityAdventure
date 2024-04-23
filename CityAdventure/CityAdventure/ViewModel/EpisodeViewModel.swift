//
//  EpisodeViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/23.
//

import Foundation

class EpisodeViewModel {
  var idList: [String] = []
  var episodeList: [Episode] = []
  
  func fetchEpisode(id: String, sendEpisode: @escaping (Episode) -> Void) {
//    DispatchQueue.global(qos: .background).async {
      FireStoreManager.shared.fetchDocument(collection: "EpisodeList",
                                            id: id) { snapshot in
        do {
          let episode = try snapshot.data(as: Episode.self)
          sendEpisode(episode)
        } catch let error {
          print("Fail to decode Episode: \(error)")
        }
      }
//    }
  }
  
  func fetchAreaEpisode(areaName: String, sendAreaEpisode: @escaping ([String]) -> Void) {
    FireStoreManager.shared.fetchFilteredDoc(collection: "EpisodeList", field: "Area", with: areaName) { docIDList in
      sendAreaEpisode(docIDList)
    }
  }
  
  func fetchEpisodeList(sendEpisodeIDList: @escaping ([String]) -> Void) {
    FireStoreManager.shared.fetchCollection(collectionName: "EpisodeList") { episodeIDList in
      self.idList = episodeIDList
      sendEpisodeIDList(episodeIDList)
    }
  }
}
