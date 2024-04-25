//
//  Section.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/22.
//

import Foundation

enum Section: String, CaseIterable {
  case profile
  case doingEpisode
  case areaEpisode = "推薦當地關卡"
  case episodeList = "所有關卡"
}

enum Item: Hashable {
  case profile(Profile)
  case episode(Episode)
}
