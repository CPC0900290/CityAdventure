//
//  ThirdTask.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/18.
//

import Foundation
import UIKit

class ThirdTaskViewController: TaskViewController {
  private var task: Properties?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    DraggableMarkerManager.shared.hideMarker()
    setupMarkerView()
    guard let episode = episodeForUser else { return }
    viewModel.fetchTask(episode: episode) { task in
      self.task = task[2]
    }
  }
  
  // MARK: - Function
  @objc func recognizeButtonPressed() {
    let recogVC = RecognizerViewController()
    recogVC.answer = "peanutsIceRoll"
    self.navigationController?.pushViewController(recogVC, animated: true)
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
  
  lazy var taskTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "請根據線索找到指定美食"
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var recognizeButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "qrcode.viewfinder"), for: .normal)
    button.tintColor = UIColor(hex: "E7F161", alpha: 1)
//    button.setBackgroundImage(UIImage(named: "qrcode.viewfinder"), for: .normal)
    button.backgroundColor = .opaqueSeparator
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(recognizeButtonPressed), for: .touchUpInside)
    return button
  }()
  
  override func setupUI() {
    view.addSubview(taskView)
    view.addSubview(locationALabel)
    view.addSubview(locationBLabel)
    taskView.addSubview(taskTitleLabel)
    taskView.addSubview(taskContentLabel)
    taskView.addSubview(recognizeButton)
    
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
      taskContentLabel.leadingAnchor.constraint(equalTo: taskView.leadingAnchor, constant: 10),
      
      taskTitleLabel.leadingAnchor.constraint(equalTo: taskView.leadingAnchor, constant: 10),
      taskTitleLabel.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 30),
      
      recognizeButton.centerXAnchor.constraint(equalTo: taskView.centerXAnchor),
      recognizeButton.topAnchor.constraint(equalTo: taskTitleLabel.bottomAnchor, constant: 50),
      recognizeButton.widthAnchor.constraint(equalTo: taskView.widthAnchor, multiplier: 0.5),
      recognizeButton.heightAnchor.constraint(equalTo: recognizeButton.widthAnchor, multiplier: 1)
    ])
  }
  
  override func setupTableView() { }
  
  private func setupMarkerView() {
    DraggableMarkerManager.shared.showMarker(in: self) {
      let mapVC = MapViewController()
      mapVC.modalPresentationStyle = .automatic
      mapVC.task = self.taskList
      self.present(mapVC, animated: true)
    }
  }
}
