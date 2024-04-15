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
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
  var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  let audioEngine = AVAudioEngine()
  
  func setupSpeech(sender: UIButton, vc: UIViewController) {
    sender.isEnabled = false
    speechRecognizer?.delegate = vc.self as? any SFSpeechRecognizerDelegate
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
      OperationQueue.main.addOperation() {
        sender.isEnabled = isButtonEnabled
      }
    }
  }
  
  func startRecording(sender: UIButton, sendAnswer: @escaping (String) -> Void) {
    
    if recognitionTask != nil {
      recognitionTask?.cancel()
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
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    let inputNode = audioEngine.inputNode
    
    guard let recognitionRequest = recognitionRequest else {
      fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
    }
    
    recognitionRequest.shouldReportPartialResults = true
    
    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
      
      var isFinal = false
      
      if result != nil {
        guard let answer = result?.bestTranscription.formattedString else { return }
        sendAnswer(answer)
        isFinal = (result?.isFinal)!
      }
      
      if error != nil || isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        sender.isEnabled = true
      }
    })
    
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    
    do {
      try audioEngine.start()
    } catch {
      print("audioEngine couldn't start because of an error.")
    }
  }
}
