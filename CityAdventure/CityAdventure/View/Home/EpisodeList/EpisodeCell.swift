//
//  EpisodeCell.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/22.
//

import Foundation
import UIKit

class EpisodeCell: UICollectionViewCell {
  static let identifier = String(describing: EpisodeCell.self)
  
  @IBOutlet weak var episodeTitleLabel: UILabel!
  @IBOutlet weak var episodeImg: UIImageView!
  
  func update(with episode: Episode) {
    episodeTitleLabel.text = episode.title
    episodeImg.layer.cornerRadius = episodeImg.frame.width / 15
    self.layer.cornerRadius = self.frame.width / 20
  }
}
