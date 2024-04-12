//
//  TaskModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/11.
//

import Foundation
struct Episode: Codable {
  var id: String
  var title: String
  var tasks: [String]
}

struct TaskA: Codable {
  var tilte: String
  var locationName: String
  var locationAddress: String
  var questionAnswer: [QuestionAnswer]
}

struct TaskB: Codable {
  var tilte: String
  var locationName: String
  var locationAddress: String
  var roadMapImg: String
}

struct TaskC: Codable {
  var tilte: String
  var locationName: String
  var locationAddress: String
  var foodImg: String
  var question: String
}

struct QuestionAnswer: Codable {
  var question: String
  var answer: String
}
