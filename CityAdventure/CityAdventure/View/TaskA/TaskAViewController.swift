//
//  TaskAViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/15.
//

import Foundation
import UIKit
import Kingfisher

class TaskAViewController: TaskViewController {
  private var task: TestTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    guard let episode = episodeForUser else { return }
    viewModel.fetchTask(episode: episode, id: 0) { task in
      self.task = task
    }
  }
  
  // MARK: - Function
  @objc func pushToScanner() {
    let scannerVC = ScannerViewController()
    self.navigationController?.pushViewController(scannerVC, animated: true)
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
    button.setImage(UIImage(named: "qrcode.viewfinder"), for: .normal)
    button.setBackgroundImage(UIImage(named: "qrcode.viewfinder"), for: .normal)
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(pushToScanner), for: .touchUpInside)
    return button
  }()
  
  override func setupUI() {
    view.addSubview(taskView)
    view.addSubview(locationALabel)
    view.addSubview(locationBLabel)
    taskView.addSubview(taskContentLabel)
    taskView.addSubview(scannerButton)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
      taskView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
      taskView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
      taskView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
      
      locationALabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
      locationALabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
      
      locationBLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
      locationBLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
      
      taskContentLabel.topAnchor.constraint(equalTo: taskView.topAnchor, constant: 80),
      taskContentLabel.centerXAnchor.constraint(equalTo: taskView.centerXAnchor),
      
      scannerButton.centerXAnchor.constraint(equalTo: taskView.centerXAnchor),
      scannerButton.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 80),
      scannerButton.widthAnchor.constraint(equalTo: taskView.widthAnchor, multiplier: 0.6),
      scannerButton.heightAnchor.constraint(equalTo: scannerButton.widthAnchor, multiplier: 1)
    ])
  }
  
  override func setupTableView() { }
}
