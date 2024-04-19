//
//  RecognizerViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/18.
//

import Foundation
import UIKit
import AVFoundation

class RecognizerViewController: UIViewController {
  private let captureSession = AVCaptureSession()
  private let videoOutput = AVCaptureVideoDataOutput()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureSession()
  }
  
  // MARK: - UI Setup
  private func configureSession() {
    captureSession.sessionPreset = AVCaptureSession.Preset.medium
    let availableDevices = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInWideAngleCamera],
      mediaType: AVMediaType.video,
      position: .back
    ).devices
    
    do {
      let input = try AVCaptureDeviceInput(device: availableDevices[0])
      captureSession.addInput(input)
      
      captureSession.addOutput(videoOutput)
      
      let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
      previewLayer.videoGravity = .resizeAspect
      previewLayer.frame = self.view.layer.bounds
      self.view.layer.addSublayer(previewLayer)
      
      DispatchQueue.global(qos: .background).async {
          self.captureSession.startRunning()
      }
    } catch {
      print(error)
      return
    }
  }
}

extension RecognizerViewController: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput,
                   didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    
  }
}
