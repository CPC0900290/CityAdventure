//
//  SpeechViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/15.
//

import Foundation
import Speech
import UIKit

class SpeechViewController: TaskViewController {
  var question: String?
  private var task: TestTask?
  
  private let speechVM = SpeechViewModel()
//  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
//  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//  private var recognitionTask: SFSpeechRecognitionTask?
//  private let audioEngine = AVAudioEngine()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    getTask()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let question = question {
      taskContentLabel.text = question
      speechVM.setupSpeech(sender: speechButton, vc: self)
    }
  }
  
  // MARK: - Function
  @objc func speechRecord() {
    if speechVM.audioEngine.isRunning {
      speechVM.audioEngine.stop()
      speechVM.recognitionRequest?.endAudio()
      speechButton.isEnabled = false
      speechButton.setTitle("Start Recording", for: .normal)
    } else {
      guard let rightAnswer = task?.questionAnswer?[0].answer else { return }
      speechVM.startRecording(rightAnswer: rightAnswer,sender: speechButton) { isRightAnswer in
        if isRightAnswer {
          print("Correct Answer! Good job!")
          self.navigationController?.popToRootViewController(animated: true)
        } else {
          print("Think about it again!")
        }
      }
      speechButton.setTitle("Stop Recording", for: .normal)
    }
  }
  
  func getTask() {
    guard let episode = episodeForUser else { return }
    viewModel.fetchTask(episode: episode, id: 0) { task in
      self.task = task
    }
  }
  
  // MARK: - UI setup
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "Question"
    label.font = UIFont(name: "PingFang TC", size: 15)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var speechButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "mic.circle"), for: .normal)
    button.setBackgroundImage(UIImage(named: "mic.circle"), for: .normal)
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(speechRecord), for: .touchUpInside)
    return button
  }()
  
  override func setupUI() {
    view.addSubview(taskView)
    view.addSubview(locationALabel)
    view.addSubview(locationBLabel)
    taskView.addSubview(taskContentLabel)
    taskView.addSubview(speechButton)
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
      
      speechButton.centerXAnchor.constraint(equalTo: taskView.centerXAnchor),
      speechButton.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 80),
      speechButton.widthAnchor.constraint(equalTo: taskView.widthAnchor, multiplier: 0.6),
      speechButton.heightAnchor.constraint(equalTo: speechButton.widthAnchor, multiplier: 1)
    ])
  }
  
  override func setupTableView() { }
  
//  private func setupSpeech() {
//    speechButton.isEnabled = false
//    speechRecognizer?.delegate = self
//    SFSpeechRecognizer.requestAuthorization { (authStatus) in
//      var isButtonEnabled = false
//
//      switch authStatus {
//      case .authorized:
//        isButtonEnabled = true
//      case .denied:
//        isButtonEnabled = false
//        print("User denied access to speech recognition")
//      case .restricted:
//        isButtonEnabled = false
//        print("Speech recognition restricted on this device")
//      case .notDetermined:
//        isButtonEnabled = false
//        print("Speech recognition not yet authorized")
//      @unknown default:
//        fatalError("Unknown Fail to get authorization from user")
//      }
//      OperationQueue.main.addOperation() {
//        self.speechButton.isEnabled = isButtonEnabled
//      }
//    }
//  }
}

extension SpeechViewController: SFSpeechRecognizerDelegate {
  func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      speechButton.isEnabled = true
    } else {
      speechButton.isEnabled = false
    }
  }
}
