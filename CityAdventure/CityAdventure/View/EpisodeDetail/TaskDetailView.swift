//
//  TaskDetailView.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/29.
//

import Foundation
import UIKit

class TaskDetailView: UIView {
  
  private let blurEffect = UIBlurEffect(style: .systemMaterialDark)
  
  private lazy var backgroundMaterial: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: blurEffect)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "任務名稱"
    label.textAlignment = .left
    label.font = UIFont(name: "PingFang TC", size: 20)
    label.textColor = UIColor(hex: "E7F161", alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var taskDistanceLabel: UILabel = {
    let label = UILabel()
    label.text = "距離"
    label.font = UIFont(name: "PingFang TC", size: 15)
    label.textColor = UIColor(hex: "E7F161", alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "任務內容"
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.numberOfLines = 0
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  let startButton: UIButton = {
    let button = UIButton()
    button.setTitle("Start", for: .normal)
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.setTitleColor(.black, for: .normal)
    button.layer.cornerRadius = 25
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(backgroundMaterial)
    setupUI()
    backgroundMaterial.layer.cornerRadius = 30
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    NSLayoutConstraint.activate([
      backgroundMaterial.topAnchor.constraint(equalTo: topAnchor),
      backgroundMaterial.leadingAnchor.constraint(equalTo: leadingAnchor),
      backgroundMaterial.trailingAnchor.constraint(equalTo: trailingAnchor),
      backgroundMaterial.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    
    [titleLabel, taskDistanceLabel, taskContentLabel, startButton].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      backgroundMaterial.contentView.addSubview($0)
    }
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: backgroundMaterial.contentView.topAnchor, constant: 10),
      titleLabel.leadingAnchor.constraint(equalTo: backgroundMaterial.contentView.leadingAnchor, constant: 20),
      
      taskDistanceLabel.topAnchor.constraint(equalTo: backgroundMaterial.contentView.topAnchor, constant: 10),
      taskDistanceLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
      taskDistanceLabel.trailingAnchor.constraint(equalTo: backgroundMaterial.contentView.trailingAnchor, constant: -20),
      
      taskContentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
      taskContentLabel.leadingAnchor.constraint(equalTo: backgroundMaterial.contentView.leadingAnchor, constant: 20),
      taskContentLabel.trailingAnchor.constraint(equalTo: backgroundMaterial.contentView.trailingAnchor, constant: -20),
      
      startButton.centerXAnchor.constraint(equalTo: backgroundMaterial.contentView.centerXAnchor),
      startButton.bottomAnchor.constraint(equalTo: backgroundMaterial.contentView.bottomAnchor, constant: -20),
      startButton.widthAnchor.constraint(equalToConstant: 200),
      startButton.heightAnchor.constraint(equalToConstant: 50)
    ])
  }
}
