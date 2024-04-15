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
  var testEpisode: TestEpisode?
  let testTaskA = TestTask(
    id: "0",
    tilte: "請找到隱藏的QRCode",
    content: "任務一",
    locationName: "位置名稱",
    locationAddress: "地址",
    questionAnswer: [QuestionAnswer(question: "問題A", answer: "答案B")]
  )
  let testTaskB = TestTask(
    id: "1",
    tilte: "請在地圖上完成指定圖示",
    content: "任務二",
    locationName: "羅東運動公園",
    locationAddress: "地址",
    roadMapImg: "urlImage"
  )
  let testTaskC = TestTask(
    id: "2",
    tilte: "請找出隱藏美食",
    content: "任務三",
    locationName: "中山公園",
    locationAddress: "地址",
    foodImg: "imageURL",
    question: "想謎題？"
  )
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
  func postEpisode() {
    do {
      let jsonDataA = try JSONEncoder().encode(testTaskA)
      let jsonDataB = try JSONEncoder().encode(testTaskA)
      let jsonDataC = try JSONEncoder().encode(testTaskC)
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
  func fetchCollection(collectionName: String, getList: @escaping ([String]) -> Void) {
    firestore.collection(collectionName).getDocuments { snapshots, error in
      if let error = error { print(error) }
      guard let snapshots = snapshots else {
        print("Get snapshot as nil when fetch collection")
        return
      }
      let list: [String] = snapshots.documents.map { document in
        return document.documentID
      }
      getList(list)
    }
  }
  
  func fetchDocument(collection: String,
                     id: String,
                     getDocument: @escaping (DocumentSnapshot) -> Void) {
    firestore.collection(collection).document(id).getDocument { snapshot, error in
      if let error = error { print(error) }
      
      guard let snapshot = snapshot else {
        print("Get snapshot as nil when fetch document")
        return
      }
//      let data = snapshot.data()
      // 傳snapshot失敗的話就傳data
      getDocument(snapshot)
    }
  }
}
