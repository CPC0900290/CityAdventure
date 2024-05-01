//
//  EpisodeVC.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/1.
//

import Foundation
import UIKit
import MapKit

enum TaskBlock {
  case taskA
  case taskB
  case taskC
}

class EpisodeVC: EpisodeDetailViewController {
  // MARK: - Properties var
  private var currentTask: TaskBlock?
  lazy var taskAButton: UIButton = {
    let button = UIButton()
    button.setTitle("A", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.tag = 0
    button.addTarget(self, action: #selector(showTasksAnnotation), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var taskBButton: UIButton = {
    let button = UIButton()
    button.setTitle("B", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.tintColor = .black
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.tag = 1
    button.addTarget(self, action: #selector(showTasksAnnotation), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var taskCButton: UIButton = {
    let button = UIButton()
    button.setTitle("C", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.tintColor = .black
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.tag = 2
    button.addTarget(self, action: #selector(showTasksAnnotation), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTaskButton()
    defaltTaskView()
    mapView.showsUserLocation = true
  }
  
  // MARK: - Setup UI
  private func defaltTaskView() {
    self.taskDetailView.startButton.setTitle("繼續", for: .normal)
    taskDetailView.startButton.isEnabled = false
    switchButtonAlpha(taskDetailView.startButton)
  }
  
  private func switchButtonAlpha(_ sender: UIButton) {
    let alpha = sender.isEnabled ? 1 : 0.5
    sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(alpha)
  }
  
  private func setupTaskButton() {
    view.addSubview(taskAButton)
    view.addSubview(taskBButton)
    view.addSubview(taskCButton)
    NSLayoutConstraint.activate([
      taskAButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      taskAButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
      taskAButton.widthAnchor.constraint(equalTo: taskAButton.heightAnchor),
      taskAButton.widthAnchor.constraint(equalToConstant: 50),
      
      taskBButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      taskBButton.topAnchor.constraint(equalTo: taskAButton.bottomAnchor, constant: 20),
      taskBButton.widthAnchor.constraint(equalTo: taskBButton.heightAnchor),
      taskBButton.widthAnchor.constraint(equalToConstant: 50),
      
      taskCButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      taskCButton.topAnchor.constraint(equalTo: taskBButton.bottomAnchor, constant: 20),
      taskCButton.widthAnchor.constraint(equalTo: taskCButton.heightAnchor),
      taskCButton.widthAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  // MARK: - Function
  private func centerForTask(coordinate: CLLocationCoordinate2D) {
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
    self.mapView.setRegion(region, animated: true)
  }
  
  @objc private func showTasksAnnotation(_ sender: UIButton) {
    sender.isSelected.toggle()
    resetButtonSelected(sender)
    switch sender.isSelected {
    case true:
      guard let allAnnotations = allAnnotations as? [CustomAnnotation] else { return }
      let annotation = allAnnotations[sender.tag]
      displayOne(annotation)

      guard let property = tasks[sender.tag].features.first?.properties else { return }
      let distance = Int(getDistanceToTask(taskCoordinate: annotation.coordinate))
      taskDetailView.titleLabel.text = property.title
      taskDetailView.taskContentLabel.text = property.content
      taskDetailView.taskDistanceLabel.text = "距離：\(distance) 公尺"
//      if distance < 300 {
//        taskDetailView.startButton.isEnabled = true
//        switchButtonAlpha(taskDetailView.startButton)
//      } else {
//        taskDetailView.startButton.isEnabled = false
//        switchButtonAlpha(taskDetailView.startButton)
//      }
      taskDetailView.startButton.isEnabled = true
      switchButtonAlpha(taskDetailView.startButton)
    case false:
      showAllAnnotations(self)
      taskDetailView.startButton.isEnabled = false
      switchButtonAlpha(taskDetailView.startButton)
      currentTask = .none
    }
  }
  
  private func displayOne(_ annotation: CustomAnnotation) {
    displayedAnnotations = [annotation]
    centerForTask(coordinate: annotation.coordinate)
  }
  
  private func resetButtonSelected(_ sender: UIButton) {
    switch sender.tag {
    case 0:
      currentTask = .taskA
      taskBButton.isSelected = false
      taskCButton.isSelected = false
    case 1:
      currentTask = .taskB
      taskAButton.isSelected = false
      taskCButton.isSelected = false
    case 2:
      currentTask = .taskC
      taskAButton.isSelected = false
      taskBButton.isSelected = false
    default:
      print("Button tag is out of range")
    }
  }
  
  @objc override func startPlaying() {
    switch currentTask {
    case .taskA:
      print("taskA")
      let taskVC = FirstTaskViewController()
      let taskContent = tasks[0].features[0].properties
      taskVC.task = taskContent
      self.navigationController?.pushViewController(taskVC, animated: true)
    case .taskB:
      print("taskB")
      let taskVC = SecondTaskViewController()
      let taskContent = tasks[1]
      taskVC.secondTask = taskContent
      self.navigationController?.pushViewController(taskVC, animated: true)
    case .taskC:
      print("taskC")
      let taskVC = ThirdTaskViewController()
      let taskContent = tasks[2].features[0].properties
      taskVC.task = taskContent
    case .none:
      break
    }
  }
}
