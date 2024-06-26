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
  
  private let slideUpAnimationController = SlideUpAnimationController()
  private var captureSession = AVCaptureSession()
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  private var qrCodeFrameView: UIView?
  var task: Properties?
  var episode: Episode?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCaptureDevice()
    setupUI()
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
  
  lazy var scanRecView: ScanRectView = {
    let view = ScanRectView()
    view.cornerColor = .lightGray
    view.cornerWidth = 3
    view.cornerLength = 30
//    view.cornerRadius = self.view.bounds.width * 0.8 / 5
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private func setupUI() {
//    view.addSubview(taskContentLabel)
    view.addSubview(scanRecView)
    view.bringSubviewToFront(scanRecView)
    NSLayoutConstraint.activate([
//      taskContentLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//      taskContentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      scanRecView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      scanRecView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      scanRecView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
      scanRecView.heightAnchor.constraint(equalTo: scanRecView.widthAnchor, multiplier: 1)
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
        speechVC.task = task
        speechVC.episodeForUser = episode
        self.captureSession.stopRunning()
        presentCustomViewController(viewController: speechVC)
      }
    }
  }
}

// MARK: - Authentication
extension ScannerViewController {
  private func setupAuthorization() {
    
  }
}

// MARK: - Animation UIViewControllerTransitioningDelegate
extension ScannerViewController: UIViewControllerTransitioningDelegate {
  func presentCustomViewController(viewController: UIViewController) {
    guard let VCs = self.view.window?.rootViewController as? UINavigationController,
          let last = VCs.viewControllers.last
    else {return}
    viewController.transitioningDelegate = self
    last.dismiss(animated: true)
    viewController.modalPresentationStyle = .overCurrentContext
    last.present(viewController, animated: false, completion: nil)
  }
  
  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    slideUpAnimationController.isPresenting = true
    return slideUpAnimationController
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    slideUpAnimationController.isPresenting = false
    return slideUpAnimationController
  }
}
