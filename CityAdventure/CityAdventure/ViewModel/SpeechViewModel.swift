//
//  SpeechViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/15.
//

import Foundation
import UIKit
import Speech

class SpeechViewModel {
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-TW"))
  var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  let audioEngine = AVAudioEngine()
  var recognitionResultHandler: (String?, Error?) -> Void = { _, _ in }
  
  func setupSpeech(sender: UIButton, viewController: UIViewController) {
    sender.isEnabled = false
    speechRecognizer?.delegate = viewController.self as? any SFSpeechRecognizerDelegate
    SFSpeechRecognizer.requestAuthorization { (authStatus) in
      var isButtonEnabled = false
      
      switch authStatus {
      case .authorized:
        isButtonEnabled = true
      case .denied:
        isButtonEnabled = false
        print("User denied access to speech recognition")
      case .restricted:
        isButtonEnabled = false
        print("Speech recognition restricted on this device")
      case .notDetermined:
        isButtonEnabled = false
        print("Speech recognition not yet authorized")
      @unknown default:
        fatalError("Unknown Fail to get authorization from user")
      }
      OperationQueue.main.addOperation {
        sender.isEnabled = isButtonEnabled
      }
    }
  }
  
  func startRecording() {
    if recognitionTask != nil {
      recognitionTask?.cancel()
      audioEngine.inputNode.removeTap(onBus: 0)
      recognitionTask = nil
    }
    
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSession.Category.record)
      try audioSession.setMode(AVAudioSession.Mode.measurement)
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      print("audioSession properties weren't set because of an error.")
    }
    
    let inputNode = audioEngine.inputNode
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    guard let recognitionRequest = recognitionRequest else { return }
    recognitionRequest.shouldReportPartialResults = true
    
    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {[weak self] result, error in
      guard let self = self else { return }
      if let result = result {
        if result.isFinal {
          self.recognitionResultHandler(result.bestTranscription.formattedString, nil)
        }
      } else if let error = error {
        self.recognitionResultHandler(nil, error)
      }
    }
    
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    
    do {
      try audioEngine.start()
    } catch {
      print("audioEngine couldn't start because of an error.")
    }
  }
  
  func stopRecording() {
    audioEngine.stop()
    recognitionRequest?.endAudio()
  }
  
  func cancelRecording() {
    audioEngine.stop()
    recognitionRequest?.endAudio()
    audioEngine.inputNode.removeTap(onBus: 0)
    recognitionTask?.cancel()
    recognitionTask = nil
    print("Recording canceled")
  }
}
