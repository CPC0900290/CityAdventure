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
  func fetchWholeData(completion: @escaping ([Episode]) -> Void) {
    FireStoreManager.shared.fetchCollection(collection: "EpisodeList") { documentIDList in
      for documentID in documentIDList {
        FireStoreManager.shared.fetchEpisodeData(id: documentID) { epsisode in
          print("ViewModel get the episode from manager")
          self.list.append(epsisode)
        }
      }
        completion(self.list)
        print("viewModel send the list to VC")
      
    }
  }
}
