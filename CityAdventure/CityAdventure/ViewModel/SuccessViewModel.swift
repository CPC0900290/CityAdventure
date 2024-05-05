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
    FireStoreManager.shared.filterDocument(collection: "Profile", field: "userID", with: userID) { snapshot in
      do {
        var data = try snapshot.data(as: Profile.self)
        var count = 0
        data.adventuringEpisode.forEach { episode in
          if episode.episodeID == episdoeID {
            data.adventuringEpisode[count].taskStatus[taskNum] = true
          }
          count += 1
        }
        FireStoreManager.shared.getDocumentReference(collection: "Profile", id: data.documentID) { ref in
          do {
            try ref.setData(from: data, mergeFields: ["adventuringEpisode"])
          } catch {
            print("SuccessVM fail to update data to ref: \(error)")
          }
        }
      } catch {
        print("EpisodeDetailViewModel fail to decode data: \(error)")
      }
    }
  }
}
