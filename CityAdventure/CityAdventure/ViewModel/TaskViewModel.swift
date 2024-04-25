//
//  TaskViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/12.
//

import Foundation
import MapKit

protocol DataModelsUpdateProtocol: AnyObject {
  func updatedDataModels()
  func updateDataModel(_ index: Int)
}

extension DataModelsUpdateProtocol {
  func updateDataModel(_ index: Int) {}
}

class TaskViewModel {
  weak var delegate: DataModelsUpdateProtocol?
  var list:[Episode] = [] {
    didSet {
      delegate?.updatedDataModels()
    }
  }
  
  // MARK: - Function
  func fetchEpisode(id: String, sendEpisode: @escaping (Episode) -> Void) {
    DispatchQueue.global(qos: .background).async {
      FireStoreManager.shared.fetchDocument(collection: "EpisodeList",
                                            id: id) { snapshot in
        do {
          let episode = try snapshot.data(as: Episode.self)
          sendEpisode(episode)
        } catch let error {
          print("Fail to decode Episode: \(error)")
        }
      }
    }
  }
  
  func fetchTask(episode: Episode, sendTask: @escaping ([Properties]) -> Void) {
    let tasks = episode.tasks
    var results: [Properties] = []
    for task in tasks {
      guard let data = task.data(using: .utf8) else { return }
      do {
        let geoResult = try JSONDecoder().decode(TaskLocations.self , from: data)
        let properties = geoResult.features[0].properties
        results.append(properties)
      } catch let error {
        print("fail to decode data from task: \(error)")
      }
    }
//    print("send testTask array from viewModel: \(results)")
    sendTask(results)
  }
}
