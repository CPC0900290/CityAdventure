//
//  SecondTaskViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/16.
//

import Foundation
import UIKit
import MapKit

class SecondTaskViewController: MapViewController {
  private var taskRouteOverlay: MKOverlay?
//  var currentPlacemark: CLPlacemark?
//  var boundingMapRect: MKMapRect?
  private var userLocations: [CLLocation] = []
  private let allLocations: [CLLocation] = [
    CLLocation(latitude: 25.040142438686885, longitude: 121.53224201653796),
    CLLocation(latitude: 25.03901711404734, longitude: 121.53223007366472),
    CLLocation(latitude: 25.038699712923076, longitude: 121.53218628313283),
    CLLocation(latitude: 25.03867085823495, longitude: 121.53187974940244),
    CLLocation(latitude: 25.038342635676855, longitude: 121.53185188269919),
    CLLocation(latitude: 25.038339028830677, longitude: 121.53258437888667),
    CLLocation(latitude: 25.040142438686885, longitude: 121.53261622654674),
    CLLocation(latitude: 25.040164079443983, longitude: 121.53225794036803)
  ]
  /*  [
   121.47221825859378,
   25.01281652230432
 ],
 [
   121.47276545057179,
   25.01311874015083
 ],
 [
   121.47249347349543,
   25.013511915653183
 ],
 [
   121.47195275716086,
   25.01322730366128
 ],
 [
   121.47222797206024,
   25.01281065398925
 ]*/
  private let testLocation: [CLLocation] = [
    CLLocation(latitude: 25.01281652230432, longitude: 121.47221825859378),
    CLLocation(latitude: 25.01311874015083, longitude: 121.47276545057179),
    CLLocation(latitude: 25.013511915653183, longitude: 121.47249347349543),
    CLLocation(latitude: 25.01322730366128, longitude: 121.47195275716086),
    CLLocation(latitude: 25.01281065398925, longitude: 121.47222797206024)
  ]
  private let startTask = CLLocationCoordinate2D(latitude: 25.038348652126686, longitude: 121.53260195052155)
  var arrivedTaskCount = 0
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    mapViewModel.setupLocationManager(self)
    mapViewModel.checkLocationAuthorization(mapView: mapView)
    setupUI()
    drawRoute(testLocation)
    locationManager?.startUpdatingLocation()
    locationManager?.startUpdatingHeading()
  }
  
  // MARK: - UI Setup
  lazy var taskContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var taskView: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = "請在地圖上完成圖片中的圖案！"
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private func setupUI() {
    view.addSubview(mapView)
    view.addSubview(taskContentView)
    taskContentView.addSubview(taskView)
    taskContentView.addSubview(taskContentLabel)
    NSLayoutConstraint.activate([
      mapView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
      mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
      mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      //      mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      taskContentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
      taskContentView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 10),
      taskContentView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
      taskContentView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/4),
      
      taskView.leadingAnchor.constraint(equalTo: taskContentView.leadingAnchor),
      taskView.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 10),
      taskView.trailingAnchor.constraint(equalTo: taskContentView.trailingAnchor),
      taskView.bottomAnchor.constraint(equalTo: taskContentView.bottomAnchor),
      
      taskContentLabel.topAnchor.constraint(equalTo: taskContentView.topAnchor, constant: 10),
      taskContentLabel.leadingAnchor.constraint(equalTo: taskContentView.leadingAnchor, constant: 10)
    ])
  }
  
  // MARK: - Function
  @objc func lastPage() {
    self.navigationController?.popViewController(animated: true)
  }
  
  func setupNavItem() {
    let navBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(lastPage))
    navBarItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = navBarItem
    navigationController?.navigationBar.prefersLargeTitles = true
    
  }
  
  // 畫出給予座標集合的路徑
  func drawRoute(_ routeData: [CLLocation]) {
    if routeData.isEmpty {
      print("==== No Coordinates to draw")
      return
    }
    
    let coordinates = routeData.map { location -> CLLocationCoordinate2D in
      return location.coordinate
    }
    
    DispatchQueue.main.async {
      self.taskRouteOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
      self.mapView.addOverlay(self.taskRouteOverlay!, level: .aboveRoads)
//      let region = MKCoordinateRegion(center: self.taskRouteOverlay!.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
//      self.mapView.setRegion(region, animated: true)
    }
  }
  
  override func setPinUsingMKPlacemark(address: String) { }
  
  // 畫出使用者路徑，並收集使用者路徑的array
  override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let currentLocation = locations.last(where: { $0.horizontalAccuracy >= 0 }) else {
      return
    }
    
    let originalCoordinate = userLocations.first?.coordinate
    userLocations.append(currentLocation)
    for location in testLocation {
      let distance = currentLocation.distance(from: location)
      if distance < 50 {
        arrivedTaskCount += 1
        showAlert()
      }
    }
    
    if originalCoordinate == nil { return }
    var area = [originalCoordinate!, currentLocation.coordinate]
    DispatchQueue.main.async {
      let polyline = MKPolyline(coordinates: &area, count: area.count)
      self.mapView.addOverlay(polyline, level: .aboveRoads) // Set different color of overlay
    }
  }
  
  private func showAlert() {
    let controller = UIAlertController(title: "恭喜！！", message: "您剛經過一個任務點", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default)
      controller.addAction(okAction)
      present(controller, animated: true)
  }
}

extension SecondTaskViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
    
    if annotationView == nil {
      annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
    } else {
      annotationView?.annotation = annotation
    }
    switch annotation.title {
    case "end":
      annotationView?.image = UIImage(named: "remove")
    case "start":
      annotationView?.image = UIImage(named: "remove")
    default:
      break
    }
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKGradientPolylineRenderer(overlay: overlay)
    renderer.setColors([UIColor(hex: "E7F161", alpha: 1)], locations: [])
    renderer.lineCap = .round
    renderer.lineWidth = 3.0
    return renderer
  }
}
