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
      guard let rightAnswer = self.task?.questionAnswerPair?.first?.answer else { return }
      DispatchQueue.main.async {
        if let text = text {
          print("Final recognized text: \(text)")
          let isRightAnswer = rightAnswer.contains(text)
          if isRightAnswer {
            let successVC = SuccessViewController()
            successVC.modalPresentationStyle = .fullScreen
            successVC.episodeID = self.episodeForUser?.id
            successVC.taskNum = 2
            self.present(successVC, animated: true)
          }
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
  
  lazy var answerTextView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont(name: "PingFang TC", size: 18)
    textView.text = "您的答案是"
    textView.isEditable = false
    textView.isSelectable = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    return textView
  }()
  
  override func setupUI() {
    view.backgroundColor = .clear
    view.addSubview(taskView)
    taskView.addSubview(backgroundMaterial)
    taskView.addSubview(taskContentLabel)
    taskView.addSubview(speechButton)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      taskView.topAnchor.constraint(equalTo: view.topAnchor),
      taskView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      taskView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      backgroundMaterial.leadingAnchor.constraint(equalTo: taskView.leadingAnchor),
      backgroundMaterial.topAnchor.constraint(equalTo: taskView.topAnchor),
      backgroundMaterial.trailingAnchor.constraint(equalTo: taskView.trailingAnchor),
      backgroundMaterial.bottomAnchor.constraint(equalTo: taskView.bottomAnchor),
      
      taskContentLabel.topAnchor.constraint(equalTo: backgroundMaterial.topAnchor, constant: 20),
      taskContentLabel.leadingAnchor.constraint(equalTo: backgroundMaterial.leadingAnchor, constant: 20),
      taskContentLabel.trailingAnchor.constraint(equalTo: backgroundMaterial.trailingAnchor, constant: -20),
      
      speechButton.centerXAnchor.constraint(equalTo: backgroundMaterial.centerXAnchor),
      speechButton.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 40),
      speechButton.widthAnchor.constraint(equalTo: backgroundMaterial.widthAnchor, multiplier: 0.5),
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
