//
//  UploadEpisode.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/22.
//

import Foundation

class UploadEpisode {
  var episode: Episode?
  let testTaskA = TaskLocations(type: "FeatureCollection",
                                features: [LocationPath(type: "Feature",
                                                        properties: Properties(id: "0",
                                                                               title: "任務",
                                                                               content: """
                                                                               探索並找到帶有標誌的QR-code獲得破關線索!
                                                                               掃描後按照指示完成任務
                                                                               """,
                                                                               locationName: "AppWorks School",
                                                                               locationAddress: "100台北市中正區仁愛路二段99號",
                                                                               questionAnswerPair: [QuestionAnswer(question: """
                                                                                                                   請問AppWorks School是否會有
                                                                                                                   """,
                                                                                                                   answer: "答案B")]),
                                                        geometry: Geometry(coordinate: [25.03838950447114, 121.53252886867381], type: "Point"))])
  let testTaskB = TaskLocations(type: "FeatureCollection",
                                features: [LocationPath(type: "Feature",
                                                        properties: Properties(id: "1",
                                                                               title: "任務",
                                                                               content: """
                                                                               請到指定任務地點，並完成任務圖形的路徑圖
                                                                               """,
                                                                               locationName: "大安森林公園",
                                                                               locationAddress: "106台北市大安區新生南路二段1號"),
                                                        geometry: Geometry(coordinate: [25.03332233595731, 121.53305121747286],
                                                                           type: "Point")),
                                           LocationPath(type: "Feature",
                                                        properties: Properties(id: "1",
                                                                               title: "任務二",
                                                                               content: "任務二任務二任務二任務二任務二",
                                                                               locationName: "大安森林公園",
                                                                               locationAddress: "106台北市大安區新生南路二段1號"),
                                                        geometry: Geometry(coordinates: [[25.033322742847076,   121.53305225771447],
                                                                                         [25.033185301376662, 121.53488324058293],
                                                                                         [25.032832757897907, 121.5360014438416],
                                                                                         [25.032039961764184,121.53449912800517],
                                                                                         [25.030230543017282,121.53534469063896],
                                                                                         [25.029133120374283, 121.53539483391842],
                                                                                         [25.032482226630975, 121.53661545882733],
                                                                                         [25.033329432985497, 121.53744842134074]],
                                                                           type: "LineString"))])
  let testTaskC = TaskLocations(type: "FeatureCollection",
                                features: [LocationPath(type: "Feature",
                                                        properties: Properties(id: "2",
                                                                               title: "任務",
                                                                               content: "請找到指定美食，購買後打開相機辨識通過任務！",
                                                                               locationName: "AppWorks School",
                                                                               locationAddress: "100台北市中正區仁愛路二段99號",
                                                                               questionAnswerPair: [QuestionAnswer(question: "食物描述，想想這是什麼吧！",
                                                                                                                   answer: "peanutsIceRoll")]),
                                                        geometry: Geometry(coordinate: [25.03838950447114, 121.53252886867381], 
                                                                           type: "Point"))])
  func postEpisode() {
    do {
      let test = FireStoreManager.shared.firestore.collection("EpisodeList")
      let document = test.document()
      
      let jsonDataA = try JSONEncoder().encode(testTaskA)
      let jsonDataB = try JSONEncoder().encode(testTaskB)
      let jsonDataC = try JSONEncoder().encode(testTaskC)
      let jsonStringA = String(data: jsonDataA, encoding: .utf8)
      let jsonStringB = String(data: jsonDataB, encoding: .utf8)
      let jsonStringC = String(data: jsonDataC, encoding: .utf8)
      guard let taskA = jsonStringA,
            let taskB = jsonStringB,
            let taskC = jsonStringC
      else { return }
      episode = Episode(title: "AppWorks School",
                        content: """
                        休息是為了走更長遠的路
                        帶你探索初探School周圍可以放鬆散心的地方
                        當受到程式碼整天的無情攻擊後
                        適當的散步放鬆是很有必要的！跟著
                        """,
                        finishedTask: [],
                        area: "台北",
                        image: "https://firebasestorage.googleapis.com/v0/b/cityadventure-98cbb.appspot.com/o/Taiwan101.jpg?alt=media&token=6085f5e2-3531-4025-abc1-0a752f8aa733",
                        tasks: [taskA,taskB,taskC],
                        id: document.documentID)
      try document.setData(from: episode)
    } catch {
      print(error)
    }
  }
  
  func postProfile() {
    do {
      let test = FireStoreManager.shared.firestore.collection("Profile").document()
      let profile = Profile(nickName: "陳品",
                            titleName: "旅遊菜鳥",
                            avatar: "url",
                            adventuringEpisode: [AdventuringEpisode(episodeID: "2FKfiPWF7OOAs1HsCHTB",
                                                               taskStatus: [false, false, false]),
                                            AdventuringEpisode(episodeID: "5PIzv445ELf88LS6s7pC",
                                                               taskStatus: [false, false, false])],
                            finishedEpisodeID: ["7j3SpUCdYdWfeDsycJW3"], 
                            userID: "",
                            documentID: test.documentID)
//      let document = test.document()
      
      try test.setData(from: profile)
    } catch {
      print(error)
    }
  }
}
