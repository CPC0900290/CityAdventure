//
//  FirstTaskViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/15.
//

import Foundation
import UIKit
import Kingfisher

class FirstTaskViewController: BaseTaskViewController {
  var task: Properties?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  // MARK: - Function
  @objc func pushToScanner() {
    let scannerVC = ScannerViewController()
    scannerVC.task = task
    scannerVC.episode = self.episodeForUser
    scannerVC.modalPresentationStyle = .formSheet
    self.present(scannerVC, animated: true)
  }
  
  // MARK: - UI Setup
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "請找到QR Code並掃描取得任務！"
    label.font = UIFont(name: "PingFang TC", size: 20)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var scannerButton: UIButton = {
    let button = UIButton()
    button.setBackgroundImage(UIImage(systemName: "qrcode.viewfinder"), for: .normal)
    button.tintColor = UIColor(hex: "E7F161", alpha: 1)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(pushToScanner), for: .touchUpInside)
    return button
  }()
  
  override func setupUI() {
    view.addSubview(taskView)
//    view.addSubview(locationALabel)
//    view.addSubview(locationBLabel)
    taskView.addSubview(taskContentLabel)
    taskView.addSubview(scannerButton)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      taskView.topAnchor.constraint(equalTo: self.view.topAnchor),
      taskView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      taskView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      
      taskContentLabel.topAnchor.constraint(equalTo: taskView.topAnchor, constant: 80),
      taskContentLabel.centerXAnchor.constraint(equalTo: taskView.centerXAnchor),
      
      scannerButton.centerXAnchor.constraint(equalTo: taskView.centerXAnchor),
      scannerButton.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 80),
      scannerButton.heightAnchor.constraint(equalTo: scannerButton.widthAnchor, multiplier: 1),
      scannerButton.widthAnchor.constraint(equalTo: taskView.widthAnchor, multiplier: 0.6)
    ])
  }
}
