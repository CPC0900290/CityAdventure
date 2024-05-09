//
//  LoginBackgroundViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/1.
//

import Foundation
import MapKit
import UIKit

class LoginBackgroundViewController: UIViewController {
  private let viewModel = MapViewModel()
  
  lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.showsUserLocation = false
//    map.delegate = self
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.setupLocationManager(self)
    setupUI()
    viewModel.checkLocationAuthorization(mapView: mapView)
    setupRegion()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    popupLoginVC()
  }
  
  // MARK: - UI setup
  private func setupUI() {
    view.addSubview(mapView)
    
    NSLayoutConstraint.activate([
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  // MARK: - Functions
  private func setupRegion() {
    guard let userLocation = viewModel.locationManager?.location?.coordinate else { return }
    let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 700, longitudinalMeters: 700)
    mapView.setRegion(region, animated: true)
  }
  
  private func popupLoginVC() {
    let loginVC = LoginViewController()
    loginVC.isModalInPresentation = true
    if let sheet = loginVC.sheetPresentationController {
      sheet.detents = [.medium()]
    }
    self.present(loginVC, animated: true)
  }
}

extension LoginBackgroundViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    viewModel.checkLocationAuthorization(mapView: mapView)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
