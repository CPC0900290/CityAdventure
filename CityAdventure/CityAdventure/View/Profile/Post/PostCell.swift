//
//  PostCell.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/26.
//

import Foundation
import UIKit
import Kingfisher

class PostCell: UICollectionViewCell {
  static let identifier = String(describing: PostCell.self)
  
  @IBOutlet weak var postImg: UIImageView!
  
  func update(with episode: Episode) {
    self.postImg.kf.setImage(with: URL(string: episode.image))
    self.layer.cornerRadius = self.frame.width / 10
  }
}
