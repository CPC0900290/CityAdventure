//
//  SpeechViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/15.
//

import Foundation
import Speech
import UIKit

class SpeechViewController: BaseTaskViewController {
  var question: String?
  var task: Properties?
  
  
  private let speechVM = SpeechViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    guard let task = task else { return }
    self.task = task
//    getTask()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let question = question {
      taskContentLabel.text = question
      speechVM.setupSpeech(sender: speechButton, viewController: self)
    }
  }
  
  // MARK: - Function
  @objc func speechRecord() {
    if speechVM.audioEngine.isRunning {
//      speechButton.isHighlighted = false
      speechVM.audioEngine.stop()
      speechVM.recognitionRequest?.endAudio()
      speechButton.isEnabled = false
//      speechButton.setTitle("Start Recording", for: .normal)
    } else {
      
      guard let rightAnswer = task?.questionAnswerPair?[0].answer else { return }
      print("=======Mic open")
      speechVM.startRecording(rightAnswer: rightAnswer,sender: speechButton) { isRightAnswer in
        if isRightAnswer {
          print(rightAnswer)
          print("Correct Answer! Good job!")
          let successVC = SuccessViewController()
          successVC.modalPresentationStyle = .fullScreen
          self.speechVM.audioEngine.stop()
          successVC.episodeID = self.episodeForUser?.id
          successVC.taskNum = 0
          self.present(successVC, animated: true)
//          self.backToRoot()
//          guard let controllers = self.navigationController?.viewControllers else { return }
//          for viewcontroller in controllers {
//            if let taskVC = viewcontroller as? EpisodeViewController {
//              self.navigationController?.popToViewController(taskVC, animated: true)
//            }
//          }
        } else {
          print("Think about it again!")
        }
      }
    }
  }
  
  func getTask() {
    guard let episode = episodeForUser else { return }
    viewModel.fetchTask(episode: episode) { task in
      self.task = task[0]
    }
  }
  
  // MARK: - UI setup
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "Question"
    label.font = UIFont(name: "PingFang TC", size: 15)
    label.numberOfLines = 0
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var speechButton: UIButton = {
    let button = UIButton()
    button.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
    button.tintColor = UIColor(hex: "E7F161", alpha: 1)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(speechRecord), for: .touchUpInside)
    return button
  }()
  
  override func setupUI() {
    view.addSubview(taskView)
    taskView.addSubview(taskContentLabel)
    taskView.addSubview(speechButton)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
      taskView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
      taskView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
      taskView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
      
      taskContentLabel.topAnchor.constraint(equalTo: taskView.topAnchor, constant: 80),
      taskContentLabel.centerXAnchor.constraint(equalTo: taskView.centerXAnchor),
      
      speechButton.centerXAnchor.constraint(equalTo: taskView.centerXAnchor),
      speechButton.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 80),
      speechButton.widthAnchor.constraint(equalTo: taskView.widthAnchor, multiplier: 0.6),
      speechButton.heightAnchor.constraint(equalTo: speechButton.widthAnchor, multiplier: 1)
    ])
  }
}

extension SpeechViewController: SFSpeechRecognizerDelegate {
  func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      speechButton.isHighlighted = false
      speechButton.isEnabled = true
    } else {
      speechButton.isHighlighted = true
      speechButton.isEnabled = false
    }
  }
}
