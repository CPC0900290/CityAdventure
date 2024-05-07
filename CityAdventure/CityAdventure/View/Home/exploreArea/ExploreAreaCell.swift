//
//  ExploreAreaCell.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/22.
//

import Foundation
import UIKit
import Kingfisher

class ExploreAreaCell: UICollectionViewCell {
  static let identifier = String(describing: ExploreAreaCell.self)
  
  @IBOutlet weak var taskTitleLabel: UILabel!
  @IBOutlet weak var exploreAreaImg: UIImageView!
  
  func update(with episode: Episode) {
    taskTitleLabel.text = episode.title
    exploreAreaImg.kf.setImage(with: URL(string: episode.image))
    self.layer.cornerRadius = self.frame.width / 15
    exploreAreaImg.layer.cornerRadius = exploreAreaImg.frame.width / 15
  }
}
