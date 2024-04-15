//
//  TaskAViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/15.
//

import Foundation
import UIKit
import AVFoundation

class TaskAViewController: TaskViewController {
  
  private var captureSession = AVCaptureSession()
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  private var qrCodeFrameView: UIView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
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
  // MARK: - UI Setup
  // DOING
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "taskContent"
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private func setupQRLayer() {
    // 初始化影片預覽層，並將其作為子層加入 viewPreview 視圖的圖層中
    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    videoPreviewLayer?.frame = self.taskView.layer.bounds
    self.taskView.layer.addSublayer(videoPreviewLayer!)
  }
  
  override func setupUI() {
    view.addSubview(taskView)
    view.addSubview(locationALabel)
    view.addSubview(locationBLabel)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
      taskView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
      taskView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
      taskView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
      
      locationALabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
      locationALabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
      
      locationBLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
      locationBLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
    ])
  }
  
  override func setupTableView() { }
}

extension TaskAViewController: AVCaptureMetadataOutputObjectsDelegate {
  
}
