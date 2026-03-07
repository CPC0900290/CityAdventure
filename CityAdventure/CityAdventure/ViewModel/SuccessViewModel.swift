//
//  SuccessViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/2.
//

import Foundation
class SuccessViewModel {
  let userDefault = UserDefaults.standard
  var profile: Profile?

  var episodeID: String?
  
  var taskStatus: [Bool] = [] {
    didSet {
      if taskStatus.allSatisfy({ $0 == true }) {
        guard let episodeID = episodeID else { return }
        updateFinishedEpisode(episodeID: episodeID)
      }
    }
  }
  
  func updateFinishingTask(episdoeID: String, taskNum: Int) {
    guard let userID = userDefault.value(forKey: UserDefaultsKeys.uid) as? String else { return }
    FireStoreManager.shared.filterDocument(collection: "Profile", field: "userID", with: userID) { [weak self] snapshot in
      do {
        var data = try snapshot.data(as: Profile.self)
        var count = 0
        data.adventuringEpisode.forEach { episode in
          if episode.episodeID == episdoeID {
            data.adventuringEpisode[count].taskStatus[taskNum] = true
            self?.episodeID = data.adventuringEpisode[count].episodeID
            self?.taskStatus = data.adventuringEpisode[count].taskStatus
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
  
  func updateFinishedEpisode(episodeID: String) {
    guard let userID = userDefault.value(forKey: UserDefaultsKeys.uid) as? String else { return }
    FireStoreManager.shared.filterDocument(collection: "Profile", field: "userID", with: userID) { [weak self] snapshot in
      do {
        var data = try snapshot.data(as: Profile.self)
        data.finishedEpisodeID.append(episodeID)
        FireStoreManager.shared.getDocumentReference(collection: "Profile", id: data.documentID) { ref in
          do {
            try ref.setData(from: data, mergeFields: ["finishedEpisodeID"])
          } catch {
            print("SuccessVM.updateFinishedEpisdoe fail to update data to ref: \(error)")
          }
        }
      } catch {
        print("EpisodeDetailViewModel fail to decode data: \(error)")
      }
    }
  }
}
