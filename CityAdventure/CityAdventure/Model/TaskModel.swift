//
//  TaskModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/11.
//

import Foundation
import MapKit

struct Episode: Codable, Hashable {
  var title: String
  var content: String
  var finishedTask: [Int] // String
  var area: String
  var image: String
  var tasks: [String] // TaskLocations
  var id: String
}

struct TaskLocations: Codable, Hashable {
  let type: String
  let features: [LocationPath]
}

struct LocationPath: Codable, Hashable {
  let type: String
  let properties: Properties
  let geometry: Geometry
}

struct Properties: Codable, Hashable {
  var identifier = UUID().uuidString
  let id: String
  let title: String
  let content: String
  let locationName: String
  let locationAddress: String
  var questionAnswerPair: [QuestionAnswer]?
  var foodImage: String?
  var task3Question: String?
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (lhs: Properties, rhs: Properties) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}

struct Geometry: Codable, Hashable {
  var coordinates: [[Float64]]?
  var coordinate: [Float64]?
  let type: String
}

struct QuestionAnswer: Codable {
  var question: String
  var answer: String
}
