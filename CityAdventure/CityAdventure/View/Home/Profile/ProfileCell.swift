//
//  episodeCell.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/22.
//

import Foundation
import UIKit

class ProfileCell: UICollectionViewCell {
  static let identifier = String(describing: ProfileCell.self)
  
  @IBOutlet weak var userTitleLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var profileImg: UIImageView!
  
  func update(with profile: Profile) {
    userTitleLabel.text = profile.titleName
    userNameLabel.text = profile.nickName
  }
}
