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
//  @objc func speechRecord() {
//    if speechVM.audioEngine.isRunning {
////      speechButton.isHighlighted = false
//      speechVM.audioEngine.stop()
//      speechVM.recognitionRequest.endAudio()
//      speechButton.isEnabled = false
//      speechVM.audioEngine.reset()
//      speechVM.audioEngine.start()
////      speechButton.setTitle("Start Recording", for: .normal)
//    } else {
//      
//      guard let rightAnswer = task?.questionAnswerPair?[0].answer else { return }
//      print("=======Mic open")
//      speechVM.startRecording(rightAnswer: rightAnswer,sender: speechButton) { isRightAnswer in
//        if isRightAnswer {
//          print(rightAnswer)
//          print("Correct Answer! Good job!")
//          let successVC = SuccessViewController()
//          successVC.modalPresentationStyle = .fullScreen
//          self.speechVM.audioEngine.stop()
//          successVC.episodeID = self.episodeForUser?.id
//          successVC.taskNum = 0
//          self.present(successVC, animated: true)
//        } else {
//          print("Think about it again!")
//        }
//      }
//    }
//  }
  
  func getTask() {
    guard let episode = episodeForUser else { return }
    viewModel.fetchTask(episode: episode) { task in
      self.task = task[0]
    }
  }
  
  @objc func buttonTouchDown() {
    speechVM.startRecording()
  }
  
  @objc func buttonTouchOutside() {
    speechVM.cancelRecording()
  }
  
  @objc func buttonTouchUpInside() {
    speechVM.stopRecording()
    speechVM.recognitionResultHandler = {text, error in
      DispatchQueue.main.async {
        if let text = text {
          print("Final recognized text: \(text)")
        } else {
          print("Error or no result")
        }
      }
      if let error = error {
        print("SpeechVC.speechVM.recognitionResultHandler got error: \(error)")
      }
    }
  }
  
  // MARK: - UI setup
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "Question"
    label.font = UIFont(name: "PingFang TC", size: 15)
    label.numberOfLines = 0
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var speechButton: UIButton = {
    let button = UIButton()
    button.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
    button.tintColor = UIColor(hex: "E7F161", alpha: 1)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
    button.addTarget(self, action: #selector(buttonTouchOutside), for: .touchUpOutside)
    button.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
    return button
  }()
  
  override func setupUI() {
    view.backgroundColor = .clear
    view.addSubview(taskView)
    taskView.addSubview(backgroundMaterial)
    taskView.addSubview(taskContentLabel)
    taskView.addSubview(speechButton)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
      taskView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
      taskView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
      taskView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
      
      backgroundMaterial.leadingAnchor.constraint(equalTo: taskView.leadingAnchor),
      backgroundMaterial.topAnchor.constraint(equalTo: taskView.topAnchor),
      backgroundMaterial.trailingAnchor.constraint(equalTo: taskView.trailingAnchor),
      backgroundMaterial.bottomAnchor.constraint(equalTo: taskView.bottomAnchor),
      
      taskContentLabel.topAnchor.constraint(equalTo: backgroundMaterial.topAnchor, constant: 80),
      taskContentLabel.leadingAnchor.constraint(equalTo: backgroundMaterial.leadingAnchor, constant: 20),
      taskContentLabel.trailingAnchor.constraint(equalTo: backgroundMaterial.trailingAnchor, constant: -20),
      
      speechButton.centerXAnchor.constraint(equalTo: backgroundMaterial.centerXAnchor),
      speechButton.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 80),
      speechButton.widthAnchor.constraint(equalTo: backgroundMaterial.widthAnchor, multiplier: 0.6),
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
