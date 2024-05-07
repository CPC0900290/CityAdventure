//
//  AdventuringTask.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/22.
//

import Foundation
import UIKit
import Kingfisher

class AdventuringTaskCell: UICollectionViewCell {
  static let identifier = String(describing: AdventuringTaskCell.self)
  
  @IBOutlet weak var adventuringTaskButton: UIButton!
  @IBOutlet weak var adventuringSloganLabelB: UILabel!
  @IBOutlet weak var adventuringTaskSloganLabel: UILabel!
  @IBOutlet weak var adventuringTaskImg: UIImageView!
  
  func update(with episode: Episode) {
    adventuringTaskImg.image = UIImage(systemName: "figure.climbing")
    adventuringTaskSloganLabel.text = "Let's Make Our"
    adventuringSloganLabelB.text = "Life so a Life"
    self.layer.cornerRadius = self.frame.width / 20
  }
}

enum EpisodeCategory: String {
  case outdoor = "figure.hiking"
  case mind = "figure.mind.and.body"
  case history = "figure.fishing"
}
