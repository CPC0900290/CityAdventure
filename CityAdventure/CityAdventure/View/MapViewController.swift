//
//  MapViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/13.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
  lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    view.addSubview(mapView)
    
    NSLayoutConstraint.activate([
      mapView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
      mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
      mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//      mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}
