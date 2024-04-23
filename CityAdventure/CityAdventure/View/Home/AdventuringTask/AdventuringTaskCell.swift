//
//  AdventuringTask.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/22.
//

import Foundation
import UIKit

class AdventuringTaskCell: UICollectionViewCell {
  static let identifier = String(describing: AdventuringTaskCell.self)
  
  @IBOutlet weak var adventuringTaskButton: UIButton!
  @IBOutlet weak var adventuringSloganLabelB: UILabel!
  @IBOutlet weak var adventuringTaskSloganLabel: UILabel!
  @IBOutlet weak var adventuringTaskImg: UIImageView!
}
