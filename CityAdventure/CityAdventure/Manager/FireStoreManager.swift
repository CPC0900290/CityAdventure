//
//  FireStoreManager.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/11.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Firebase

class FireStoreManager {
  static var shared = FireStoreManager()
  let firestore = Firestore.firestore()
  var episode: Episode?
  let taskA = TaskA(
    id: "0",
    tilte: "請找到隱藏的QRCode",
    content: "任務一",
    locationName: "位置名稱",
    locationAddress: "地址",
    questionAnswer: [QuestionAnswer(question: "問題A", answer: "答案B")]
  )
  let taskB = TaskB(
    id: "1",
    tilte: "請在地圖上完成指定圖示",
    content: "任務二",
    locationName: "羅東運動公園",
    locationAddress: "地址",
    roadMapImg: "urlImage"
  )
  let taskC = TaskC(
    id: "2",
    tilte: "請找出隱藏美食",
    content: "任務三",
    locationName: "中山公園",
    locationAddress: "地址",
    foodImg: "imageURL",
    question: "想謎題？"
  )
  func makeJson() {
    do {
      let jsonDataA = try JSONEncoder().encode(taskA)
      let jsonDataB = try JSONEncoder().encode(taskB)
      let jsonDataC = try JSONEncoder().encode(taskC)
      let jsonStringA = String(data: jsonDataA, encoding: .utf8)
      let jsonStringB = String(data: jsonDataB, encoding: .utf8)
      let jsonStringC = String(data: jsonDataC, encoding: .utf8)
      guard let taskA = jsonStringA,
            let taskB = jsonStringB,
            let taskC = jsonStringC
      else { return }
      episode = Episode(title: "宜蘭關卡", tasks: [taskA,taskB,taskC])
      let test = firestore.collection("EpisodeList")
      let document = test.document()
      try document.setData(from: episode)
    } catch {
      print(error)
    }
  }

  // MARK: - Function
  // fetch episode ID list
  func fetchCollection(collection: String, getEpisodeIDList: @escaping ([String]) -> Void) {
    var documentIDList: [String] = []
    firestore.collection(collection).getDocuments { snapshot, error in
      if let error = error {
        print("Fail to get episodeIDList snapshot: \(error)")
      }
      guard let snapshot = snapshot else {
        print("collection episodeList snapshot is empty")
        return
      }
      let episodes: [String] = snapshot.documents.map { document in
        documentIDList.append(document.documentID)
        return document.documentID
      }
      print(episodes)
      getEpisodeIDList(episodes)
    }
  }
  // fetch spesific episode
  func fetchEpisodeData(id: String, getEpisode: @escaping (Episode) -> Void) {
    let episodeRef = firestore.collection("EpisodeList").document(id)
    episodeRef.getDocument { document, error in
      if let error = error {
        print("Fail to get document of episode: \(error)")
      }
      guard let document = document else {
        print("Fail to get episode document")
        return
      }
      do {
        let episode = try document.data(as: Episode.self)
        getEpisode(episode)
      } catch {
        print("Fail to decode document to Episode: \(error)")
      }
    }
  }
  
  // fetch the spesific episode
  func fetchData(id: String, curentTask: @escaping (Episode) -> Void) {
    
  }
}
