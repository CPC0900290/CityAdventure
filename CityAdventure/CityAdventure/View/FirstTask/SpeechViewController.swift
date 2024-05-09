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
    view.backgroundColor = .clear
    view.isOpaque = false
    setupUI()
    guard let task = task else { return }
    self.task = task
//    getTask()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    taskView.layer.cornerRadius = taskView.frame.width / 30
    backgroundMaterial.layer.cornerRadius = backgroundMaterial.frame.width / 30
    answerTextView.layer.cornerRadius = taskView.frame.width / 20
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
    DispatchQueue.main.async {
      self.answerTextView.backgroundColor = .darkGray
      self.answerTextView.layer.borderWidth = 0
      self.answerTextView.text = "回答中..."
    }
  }
  
  @objc func buttonTouchOutside() {
    speechVM.cancelRecording()
    DispatchQueue.main.async {
      self.answerTextView.backgroundColor = .darkGray
      self.answerTextView.layer.borderWidth = 0
      self.answerTextView.text = "請以語音回答下方問題！"
    }
  }
  
  @objc func buttonTouchUpInside() {
    speechVM.stopRecording()
    speechVM.recognitionResultHandler = {text, error in
      guard let rightAnswer = self.task?.questionAnswerPair?.first?.answer else { return }
      DispatchQueue.main.async {
        if let text = text {
          print("Final recognized text: \(text)")
          self.answerTextView.text = text
          let isRightAnswer = rightAnswer.contains(text)
          if isRightAnswer {
            let successVC = SuccessViewController()
            successVC.modalPresentationStyle = .fullScreen
            successVC.episodeID = self.episodeForUser?.id
            successVC.taskNum = 0
            self.present(successVC, animated: true)
          } else {
            self.answerTextView.backgroundColor = .systemPink
            self.answerTextView.layer.borderColor = UIColor.red.cgColor
            self.answerTextView.layer.borderWidth = 1
            self.answerTextView.text = "答案錯誤：\(text)，請再試試！"
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
  
  @objc func closeAction() {
    self.dismiss(animated: true)
  }
  
  // MARK: - UI setup
  lazy var closeButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "xmark"), for: .normal)
    button.tintColor = .white
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
    return button
  }()
  
  lazy var taskTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "請以語音回答下方問題！"
    label.font = UIFont(name: "PingFang TC", size: 20)
    label.textColor = UIColor(hex: "E7F161", alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "Question"
    label.font = UIFont(name: "PingFang TC", size: 18)
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
  
  lazy var answerLabel: UILabel = {
    let label = UILabel()
    label.text = "您的答案："
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var answerTextView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont(name: "PingFang TC", size: 18)
    textView.text = "請作答..."
    textView.isScrollEnabled = false
    textView.isUserInteractionEnabled = false
    textView.isEditable = false
    textView.isSelectable = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    return textView
  }()
  
  override func setupUI() {
    view.backgroundColor = .clear
    view.addSubview(taskView)
    taskView.addSubview(backgroundMaterial)
    taskView.addSubview(taskTitleLabel)
    taskView.addSubview(taskContentLabel)
    taskView.addSubview(closeButton)
    taskView.addSubview(answerLabel)
    taskView.addSubview(answerTextView)
    taskView.addSubview(speechButton)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//      taskView.topAnchor.constraint(equalTo: view.topAnchor),
      taskView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      taskView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      backgroundMaterial.leadingAnchor.constraint(equalTo: taskView.leadingAnchor),
      backgroundMaterial.topAnchor.constraint(equalTo: taskView.topAnchor),
      backgroundMaterial.trailingAnchor.constraint(equalTo: taskView.trailingAnchor),
      backgroundMaterial.bottomAnchor.constraint(equalTo: taskView.bottomAnchor),
      
      taskTitleLabel.topAnchor.constraint(equalTo: backgroundMaterial.topAnchor, constant: 20),
      taskTitleLabel.leadingAnchor.constraint(equalTo: backgroundMaterial.leadingAnchor, constant: 20),
      taskTitleLabel.trailingAnchor.constraint(equalTo: backgroundMaterial.trailingAnchor, constant: -20),
      
      closeButton.topAnchor.constraint(equalTo: backgroundMaterial.topAnchor, constant: 10),
      closeButton.trailingAnchor.constraint(equalTo: backgroundMaterial.trailingAnchor, constant: -10),
      closeButton.heightAnchor.constraint(equalToConstant: 20),
      closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor, multiplier: 1),
      
      taskContentLabel.leadingAnchor.constraint(equalTo: taskTitleLabel.leadingAnchor),
      taskContentLabel.trailingAnchor.constraint(equalTo: taskTitleLabel.trailingAnchor),
      taskContentLabel.topAnchor.constraint(equalTo: taskTitleLabel.bottomAnchor, constant: 10),
      
      answerLabel.leadingAnchor.constraint(equalTo: taskTitleLabel.leadingAnchor),
      answerLabel.trailingAnchor.constraint(equalTo: taskTitleLabel.trailingAnchor),
      answerLabel.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 10),
      
      answerTextView.leadingAnchor.constraint(equalTo: taskTitleLabel.leadingAnchor),
      answerTextView.trailingAnchor.constraint(equalTo: taskTitleLabel.trailingAnchor),
      answerTextView.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 5),
      answerTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
      
      speechButton.centerXAnchor.constraint(equalTo: backgroundMaterial.centerXAnchor),
      speechButton.topAnchor.constraint(equalTo: answerTextView.bottomAnchor, constant: 10),
      speechButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
      speechButton.widthAnchor.constraint(equalTo: backgroundMaterial.widthAnchor, multiplier: 0.4),
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
