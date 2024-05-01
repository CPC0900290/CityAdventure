//
//  LoginViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/30.
//

import Foundation

class LoginViewModel {
  func postProfile(nickName: String, userID: String) {
    let document = FireStoreManager.shared.firestore.collection("Profile").document()
    let profile = Profile(nickName: nickName,
                          titleName: "旅遊菜鳥",
                          avatar: "person.circle.fill",
                          adventuringEpisode: [],
                          finishedEpisodeID: [],
                          userID: userID,
                          documentID: document.documentID)
    do {
      try document.setData(from: profile)
    } catch {
      print("LoginViewModel fail to post data to firebase: \(error)")
    }
      
  }
}
