//
//  RecognizerViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/18.
//

import Foundation
import UIKit
import AVFoundation
import CoreML
import Vision

class RecognizerViewController: UIViewController {
  var answer: String?
  private let captureSession = AVCaptureSession()
  private let videoOutput = AVCaptureVideoDataOutput()
  private var input: AVCaptureDeviceInput?
  private var bufferSize: CGSize = .zero
  private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureSession()
  }
  
  // MARK: - UI Setup
  private func configureSession() {
    let availableDevices = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInWideAngleCamera],
      mediaType: AVMediaType.video,
      position: .back
    ).devices.first
    
    captureSession.sessionPreset = AVCaptureSession.Preset.medium
    // Add input data
    do {
      let input = try AVCaptureDeviceInput(device: availableDevices!)
      guard captureSession.canAddInput(input) else {
        print("Could not add video device input to the session")
        return
      }
      captureSession.addInput(input)
    } catch {
      print("Could not create video device input: \(error)")
      return
    }
    
    // Add output data
    if captureSession.canAddOutput(videoOutput) {
      captureSession.addOutput(videoOutput)
        // Add a video data output
      videoOutput.alwaysDiscardsLateVideoFrames = true
      videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
      videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
    } else {
      print("Could not add video data output to the session")
      return
    }
    
    let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    previewLayer.videoGravity = .resizeAspect
    previewLayer.frame = self.view.layer.bounds
    self.view.layer.addSublayer(previewLayer)
    DispatchQueue.global(qos: .background).async {
      self.captureSession.startRunning()
    }
  }
}

extension RecognizerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput,
                     didOutput sampleBuffer: CMSampleBuffer,
                     from connection: AVCaptureConnection) {
    let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
    
    do {
      let modelConfiguration = MLModelConfiguration()
      let model = try FoodFromTaiwan(configuration: modelConfiguration)
      let input = FoodFromTaiwanInput(image: pixelBuffer!)
      let output = try model.prediction(input: input)
      
      guard let answer = answer,
            let similarity = output.classLabelProbs[answer]
      else { return }
      if similarity > 0.6 {
        // TODO 成功畫面
        print(answer)
        self.captureSession.stopRunning()
        DispatchQueue.main.async {
          self.navigationController?.popToRootViewController(animated: true)
        }
      }
      print(output.classLabel)
    } catch {
      print(error.localizedDescription)
    }
  }
}
