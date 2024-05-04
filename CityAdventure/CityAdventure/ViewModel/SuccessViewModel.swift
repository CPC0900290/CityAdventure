//
//  SuccessViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/2.
//

import Foundation
class SuccessViewModel {
  func updateFinishingTask(episdoeID: String, taskNum: Int) {
    let userDefault = UserDefaults()
    guard let userID = userDefault.value(forKey: "uid") as? String else { return }
    FireStoreManager.shared.getDocumentReference(collection: "Profile", id: userID) { ref in
      ref.getDocument { snapshot, error in
        if let error = error {
          print("EpisodeDetailViewModel fail to get document: \(error)")
          return
        }
        guard let snapshot = snapshot else { return }
        do {
          var data = try snapshot.data(as: Profile.self)
          var count = 0
          data.adventuringEpisode.forEach { episode in
            if episode.episodeID == episdoeID {
              data.adventuringEpisode[count].taskStatus[taskNum] = true
            }
            count += 1
          }
          try ref.setData(from: data, mergeFields: ["adventuringEpisode"])
        } catch {
          print("EpisodeDetailViewModel fail to decode data: \(error)")
        }
      }
    }
  }
}
