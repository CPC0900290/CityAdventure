//
//  ThirdTask.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/18.
//

import Foundation
import UIKit

class ThirdTaskViewController: BaseTaskViewController {
  var task: Properties?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  // MARK: - Function
  @objc func recognizeButtonPressed() {
    let recogVC = RecognizerViewController()
    recogVC.answer = "mango_shaved_ice"
    recogVC.modalPresentationStyle = .formSheet
    self.present(recogVC, animated: true)
  }
  
  // MARK: - UI Setup
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "請根據線索找到指定美食！"
    label.font = UIFont(name: "PingFang TC", size: 20)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var taskTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "請找到一個黃色的食物"
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var recognizeButton: UIButton = {
    let button = UIButton()
    button.setBackgroundImage(UIImage(systemName: "qrcode.viewfinder"), for: .normal)
    button.tintColor = UIColor(hex: "E7F161", alpha: 1)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(recognizeButtonPressed), for: .touchUpInside)
    return button
  }()
  
  override func setupUI() {
    view.addSubview(taskView)
    taskView.addSubview(taskTitleLabel)
    taskView.addSubview(taskContentLabel)
    taskView.addSubview(recognizeButton)
    
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      taskView.topAnchor.constraint(equalTo: self.view.topAnchor),
      taskView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      taskView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      
      taskContentLabel.topAnchor.constraint(equalTo: taskView.topAnchor, constant: 80),
      taskContentLabel.leadingAnchor.constraint(equalTo: taskView.leadingAnchor, constant: 10),
      
      taskTitleLabel.leadingAnchor.constraint(equalTo: taskView.leadingAnchor, constant: 10),
      taskTitleLabel.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 30),
      
      recognizeButton.centerXAnchor.constraint(equalTo: taskView.centerXAnchor),
      recognizeButton.topAnchor.constraint(equalTo: taskTitleLabel.bottomAnchor, constant: 50),
      recognizeButton.widthAnchor.constraint(equalTo: taskView.widthAnchor, multiplier: 0.5),
      recognizeButton.heightAnchor.constraint(equalTo: recognizeButton.widthAnchor, multiplier: 1)
    ])
  }
}
