//
//  TaskModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/11.
//

import Foundation
struct Episode: Codable {
  var title: String
  var tasks: [String]
}

struct TaskA: Codable {
  var id: String
  var tilte: String
  var content: String
  var locationName: String
  var locationAddress: String
  var questionAnswer: [QuestionAnswer]
}

struct TaskB: Codable {
  var id: String
  var tilte: String
  var content: String
  var locationName: String
  var locationAddress: String
  var roadMapImg: String
}

struct TaskC: Codable {
  var id: String
  var tilte: String
  var content: String
  var locationName: String
  var locationAddress: String
  var foodImg: String
  var question: String
}

struct QuestionAnswer: Codable {
  var question: String
  var answer: String
}
