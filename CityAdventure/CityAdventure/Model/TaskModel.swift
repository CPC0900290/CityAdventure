//
//  TaskModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/11.
//

import Foundation
// struct EpisodeCollection: Codable, Hashable {
//  var title: String
//  var episodes: [Episode]
//  var identifier = UUID().uuidString
//  
//  func hash(into hasher: inout Hasher) {
//    hasher.combine(identifier)
//  }
//  
//  static func == (lhs: EpisodeCollection, rhs: EpisodeCollection) -> Bool {
//    return lhs.identifier == rhs.identifier
//  }
// }

struct Episode: Codable, Hashable {
  var title: String
  var tasks: [String]
}

struct TestTask: Codable {
  var id: String
  var tilte: String
  var content: String
  var locationName: String
  var locationDetail: LocationDetail?
  var locationAddress: String
  var questionAnswer: [QuestionAnswer]?
  var roadMapImg: String?
  var foodImg: String?
  var question: String?
}

struct LocationDetail: Codable {
  var locationName: String
  var locationAddress: String
  var coordinate: String
}

struct QuestionAnswer: Codable {
  var question: String
  var answer: String
}
