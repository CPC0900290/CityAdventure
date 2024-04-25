//
//  PostCell.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/26.
//

import Foundation
import UIKit

class PostCell: UICollectionViewCell {
  static let identifier = String(describing: PostCell.self)
  
  @IBOutlet weak var postImg: UIImageView!
  
  func update(with profile: Profile) {
    
  }
}
