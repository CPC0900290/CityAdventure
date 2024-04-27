//
//  ProfileViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/27.
//

import Foundation

protocol ProfileModelsUpdateProtocol: AnyObject {
  func updatedDataModels()
  func updateDataModel(_ index: Int)
}

extension ProfileModelsUpdateProtocol {
  func updateDataModel(_ index: Int) {}
}

class ProfileViewModel {
  private var delegate: ProfileModelsUpdateProtocol?
  var finishedList: [Episode] = [] {
    didSet {
      delegate?.updatedDataModels()
    }
  }
  
  func fetchEpisode(id: String, getData sendData: @escaping (Episode) -> Void) {
    DispatchQueue.global(qos: .background).async {
      FireStoreManager.shared.fetchDocument(collection: "EpisodeList", id: id) { documentSnapshot in
        do {
          let result = try documentSnapshot.data(as: Episode.self)
          sendData(result)
        } catch {
          print("ProfileViewModel fail to decode data from Firebase: \(error)")
        }
      }
    }
  }
}
