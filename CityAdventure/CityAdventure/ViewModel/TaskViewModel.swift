//
//  TaskViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/12.
//

import Foundation
protocol DataModelsUpdateProtocol: AnyObject {
  func updatedDataModels()
  func updateDataModel(_ index: Int)
}

extension DataModelsUpdateProtocol {
  func updateDataModel(_ index: Int) {}
}

class TaskViewModel {
  weak var delegate: DataModelsUpdateProtocol?
  private var list:[Episode] = [] {
    didSet {
      delegate?.updatedDataModels()
    }
  }
  
  // MARK: - Function
  func fetchData(sendData: @escaping (Episode) -> Void) {
    FireStoreManager.shared.fetchCollection(collectionName: "EpisodeList") { documentList in
      documentList.forEach { documentID in
        FireStoreManager.shared.fetchDocument(collection: "EpisodeList",
                                                           id: documentID) { snapshot in
          do {
            let episode = try snapshot.data(as: Episode.self)
            sendData(episode)
          } catch let error {
            print("Fail to decode Episode: \(error)")
          }
        }
      }
    }
  }
}
