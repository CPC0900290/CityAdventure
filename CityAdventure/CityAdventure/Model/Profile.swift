//
//  Profile.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/23.
//

import Foundation

struct Profile: Hashable {
  var nickName: String
  var titleName: String
  var avatar: String
  var playingTaskID: [String]?
  var finishedTaskID: [String]?
  var latestRoadMapLocation: String?
  var taskProgress: String?
}
