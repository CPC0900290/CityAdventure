//
//  ScannerViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/15.
//

import Foundation
import UIKit
import AVFoundation

class ScannerViewController: UIViewController {
  
  private var captureSession = AVCaptureSession()
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  private var qrCodeFrameView: UIView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCaptureDevice()
  }
  
  // MARK: - Function
  private func setupCaptureDevice() {
    guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
      print("Failed to get the camera device")
      return
    }
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      
      let captureMetadataOutput = AVCaptureMetadataOutput()
      captureSession.addOutput(captureMetadataOutput)
      
      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
      
      setupQRLayer()
      
      DispatchQueue.global(qos: .background).async {
          self.captureSession.startRunning()
      }
    } catch {
      print(error)
      return
    }
  }
  
  // MARK: - Setup UI
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "taskContent"
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private func setupUI() {
    view.addSubview(taskContentLabel)
    NSLayoutConstraint.activate([
      taskContentLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      taskContentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }
  
  private func setupQRLayer() {
    // 初始化影片預覽層，並將其作為子層加入 viewPreview 視圖的圖層中
    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    videoPreviewLayer?.frame = self.view.layer.bounds
    self.view.layer.addSublayer(videoPreviewLayer!)
  }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    if metadataObjects.isEmpty {
      qrCodeFrameView?.frame = CGRect.zero
      taskContentLabel.text = "No QR code is detected"
      return
    }
    
    let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
    guard let object = metadataObj else { return }
    
    if object.type == AVMetadataObject.ObjectType.qr {
      guard let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: object) else { return }
      
      qrCodeFrameView?.frame = barCodeObject.bounds
      
      if let question = object.stringValue {
        let speechVC = SpeechViewController()
        speechVC.question = question
        self.navigationController?.pushViewController(speechVC, animated: true)
        self.captureSession.stopRunning()
      }
    }
  }
}
