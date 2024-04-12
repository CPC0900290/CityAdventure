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
    tilte: "請找到隱藏的QRCode",
    locationName: "位置名稱",
    locationAddress: "地址",
    questionAnswer: [QuestionAnswer(question: "問題A", answer: "答案B")]
  )
  let taskB = TaskB(
    tilte: "請在地圖上完成指定圖示",
    locationName: "羅東運動公園",
    locationAddress: "地址",
    roadMapImg: "urlImage"
  )
  let taskC = TaskC(
    tilte: "請找出隱藏美食",
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
      episode = Episode(id: "ajsdklfi", title: "宜蘭關卡", tasks: [taskA,taskB,taskC])
      let test = firestore.collection("EpisodeList")
      let document = test.document()
      try document.setData(from: episode)
    } catch {
      print(error)
    }
  }

  func fetchTask() {
    firestore.collection("TestData").getDocuments { snapshot, error in
      guard let snapshot = snapshot else { return }
      let articles = snapshot.documents.compactMap { (document) -> Episode? in
        do {
          return try document.data(as: Episode.self)
        } catch {
          print("Decoding error for document \(document.documentID): \(error)")
          return nil
        }
      }
      print(articles)
    }
  }
}
