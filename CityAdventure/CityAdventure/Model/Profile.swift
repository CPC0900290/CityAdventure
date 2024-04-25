//
//  Profile.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/23.
//

import Foundation

struct Profile: Hashable, Codable {
  var nickName: String
  var titleName: String
  var avatar: String
  var adventuringEpisode: [AdventuringEpisode]
  var finishedTaskID: [String]
}

struct AdventuringEpisode: Hashable, Codable {
  var episodeID: String
//  var tasks: [TaskStatus]
  var taskStatus: [Bool]
}

enum TaskStatus: String, Hashable, Codable {
  case completed
  case inProgress = "in-progress"
  case notStarted = "not-started"
}
