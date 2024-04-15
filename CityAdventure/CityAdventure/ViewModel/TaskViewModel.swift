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
  var list:[Episode] = [] {
    didSet {
      delegate?.updatedDataModels()
    }
  }
  
  // MARK: - Function
  func fetchData(sendData: @escaping (Episode) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      FireStoreManager.shared.fetchCollection(collectionName: "EpisodeList") { documentList in
        documentList.forEach { documentID in
          FireStoreManager.shared.fetchDocument(collection: "EpisodeList",
                                                id: documentID) { snapshot in
            do {
              let episode = try snapshot.data(as: Episode.self)
              self.list.append(episode)
              sendData(episode)
            } catch let error {
              print("Fail to decode Episode: \(error)")
            }
          }
        }
      }
    }
  }
  
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
  
  func fetchTask(episode: Episode, id: Int, sendTask: @escaping (TestTask) -> Void) {
    let task = episode.tasks[id]
    let data = task.data(using: .utf8)
    print(task)
    guard let data = data else { return }
    do {
      let result = try JSONDecoder().decode(TestTask.self, from: data)
      sendTask(result)
    } catch let error {
      print("fail to decode data from task: \(error)")
    }
  }
}
