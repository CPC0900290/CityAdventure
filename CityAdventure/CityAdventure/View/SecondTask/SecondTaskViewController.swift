//
//  SecondTaskViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/16.
//

import Foundation
import UIKit
import MapKit

class SecondTaskViewController: EpisodeDetailViewController {
  var secondTask: TaskLocations?
  private var taskRouteOverlay: MKOverlay?
  /// A custom `MKOverlay` that contains the path a user travels.
  var breadcrumbs: BreadcrumbPath!
  
  /// A custom overlay renderer object that draws the data in `crumbs` on the map.
  var breadcrumbPathRenderer: BreadcrumbPathRenderer?
  private var userLocations: [CLLocation] = []
  private var allLocations: [CLLocation] = []
  private let testLocation: [CLLocation] = [
    CLLocation(latitude: 25.01281652230432, longitude: 121.47221825859378),
    CLLocation(latitude: 25.01311874015083, longitude: 121.47276545057179),
    CLLocation(latitude: 25.013511915653183, longitude: 121.47249347349543),
    CLLocation(latitude: 25.01322730366128, longitude: 121.47195275716086),
    CLLocation(latitude: 25.01281065398925, longitude: 121.47222797206024)
  ]
  private var arrivedTaskCount = 0
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    mapView.delegate = self
    mapView.showsUserLocation = true
    zoomInLocation(mapView.userLocation.coordinate)
    getUserLocation()
    setupUI()
    fetchLocation()
    drawRoute(allLocations)
    viewModel.locationManager?.startUpdatingLocation()
    viewModel.locationManager?.startUpdatingHeading()
  }
  
  override func viewDidLayoutSubviews() {
    taskView.layer.cornerRadius = taskView.frame.width / 30
    taskView.clipsToBounds = true
  }
  
  // MARK: - UI Setup
  private let blurEffect = UIBlurEffect(style: .systemMaterialDark)
  
  lazy var backgroundMaterial: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: blurEffect)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var taskView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var taskTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "任務B"
    label.font = UIFont(name: "PingFang TC", size: 20)
    label.textColor = UIColor(hex: "E7F161", alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var taskContentLabel: UILabel = {
    let label = UILabel()
    label.text = """
請完成地圖上的路徑圖案！
完成路徑圖後，請點擊按鈕提交！
"""
    label.font = UIFont(name: "PingFang TC", size: 20)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var submitButton: UIButton = {
    let button = UIButton()
    button.setTitle("提交", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 25
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(submitButtonClicked), for: .touchUpInside)
    return button
  }()
  
  lazy var backButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
    button.tintColor = .white
    button.backgroundColor = .clear
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(lastPage), for: .touchUpInside)
    return button
  }()
  
  override func setupUI() {
    view.addSubview(mapView)
    view.addSubview(taskView)
    view.addSubview(backButton)
    taskView.addSubview(backgroundMaterial)
    backgroundMaterial.contentView.addSubview(taskTitleLabel)
    backgroundMaterial.contentView.addSubview(taskContentLabel)
    backgroundMaterial.contentView.addSubview(submitButton)
    
    NSLayoutConstraint.activate([
      backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
      backButton.heightAnchor.constraint(equalToConstant: 80),
      backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1),
      
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      taskView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
      taskView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
      taskView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
      
      backgroundMaterial.contentView.topAnchor.constraint(equalTo: taskView.topAnchor),
      backgroundMaterial.contentView.leadingAnchor.constraint(equalTo: taskView.leadingAnchor),
      backgroundMaterial.contentView.bottomAnchor.constraint(equalTo: taskView.bottomAnchor),
      backgroundMaterial.contentView.trailingAnchor.constraint(equalTo: taskView.trailingAnchor),
      
      taskTitleLabel.leadingAnchor.constraint(equalTo: backgroundMaterial.contentView.leadingAnchor, constant: 20),
      taskTitleLabel.topAnchor.constraint(equalTo: backgroundMaterial.contentView.topAnchor, constant: 20),
      
      taskContentLabel.topAnchor.constraint(equalTo: taskTitleLabel.bottomAnchor, constant: 10),
      taskContentLabel.leadingAnchor.constraint(equalTo: taskTitleLabel.leadingAnchor),
      
      submitButton.centerXAnchor.constraint(equalTo: backgroundMaterial.contentView.centerXAnchor),
      submitButton.bottomAnchor.constraint(equalTo: backgroundMaterial.contentView.bottomAnchor, constant: -20),
      submitButton.topAnchor.constraint(equalTo: taskContentLabel.bottomAnchor, constant: 20),
      submitButton.widthAnchor.constraint(equalToConstant: 200),
      submitButton.heightAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  // MARK: - Function
  @objc private func submitButtonClicked() {
//    guard !userLocations.isEmpty,
//          let currentLocation = userLocations.last
//    else { return }
//    for location in allLocations {
//      let distance = currentLocation.distance(from: location)
//      if distance < 50 {
//        arrivedTaskCount += 1
//        print("Arrived task spot!!!!!!!!!!!!!!!!!!!!!!!!")
        if arrivedTaskCount > allLocations.count / 2 {
          viewModel.locationManager?.stopUpdatingLocation()
          viewModel.locationManager?.stopUpdatingHeading()
          let successVC = SuccessViewController()
          successVC.modalPresentationStyle = .fullScreen
          successVC.episodeID = self.episode?.id
          successVC.taskNum = 1
          self.present(successVC, animated: true)
        }
//      }
//    }
  }
  
  private func fetchLocation() {
    guard let secondTask = secondTask,
          let points = secondTask.features[1].geometry.coordinates
    else { return }
    for point in points {
      let location = CLLocation(latitude: point[0], longitude: point[1])
      allLocations.append(location)
    }
  }
  
  private func getUserLocation() {
    if let breadcrumbs {
      mapView.removeOverlay(breadcrumbs)
      breadcrumbPathRenderer = nil
    }
    
    // Create a fresh path when starting to record the locations.
    breadcrumbs = BreadcrumbPath()
    mapView.addOverlay(breadcrumbs, level: .aboveRoads)
  }
  
  @objc override func lastPage() {
    viewModel.locationManager?.stopUpdatingLocation()
    viewModel.locationManager?.stopUpdatingHeading()
    self.dismiss(animated: true)
  }
  
  // 畫出給予座標集合的路徑Work
  private func drawRoute(_ routeData: [CLLocation]) {
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
    }
  }
  
  private func zoomInLocation(_ coordinate: CLLocationCoordinate2D) {
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
    self.mapView.setRegion(region, animated: true)
  }
  
  // 畫出使用者路徑，並收集使用者路徑的array
  override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let currentLocation = locations.last(where: { $0.horizontalAccuracy >= 0 }) else {
      return
    }
    
    for location in locations {
      displayNewBreadcrumbOnMap(location)
    }
    
    userLocations.append(currentLocation)
    for location in allLocations {
      let distance = currentLocation.distance(from: location)
      if distance < 50 {
        arrivedTaskCount += 1
        print("Arrived task spot!!!!!!!!!!!!!!!!!!!!!!!!")
//        if arrivedTaskCount > allLocations.count / 2 {
//          viewModel.locationManager?.stopUpdatingLocation()
//          viewModel.locationManager?.stopUpdatingHeading()
//          let successVC = SuccessViewController()
//          successVC.modalPresentationStyle = .fullScreen
//          successVC.episodeID = self.episode?.id
//          successVC.taskNum = 1
//          self.present(successVC, animated: true)
//        }
      }
    }
  }
  
  override func showAllAnnotations(_ snder: Any) { }
}

// MARK: - MapViewDelegate
extension SecondTaskViewController {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let overlay = overlay as? MKPolyline {
      
      return createPolylineRenderer(for: overlay)
      
    } else if let overlay = overlay as? BreadcrumbPath {
      
      if breadcrumbPathRenderer == nil {
        breadcrumbPathRenderer = BreadcrumbPathRenderer(crumbPath: overlay)
      }
      
      return breadcrumbPathRenderer!
    }
    return MKOverlayRenderer()
  }
  
  func createPolylineRenderer(for line: MKPolyline) -> MKPolylineRenderer {
    let renderer = MKPolylineRenderer(polyline: line)
    
    if line.coordinates == allLocations.map({ $0.coordinate }) {
      renderer.strokeColor = UIColor(hex: "E7F161", alpha: 1)
      renderer.lineWidth = 2
      renderer.lineDashPattern = [20 as NSNumber,
                                  10 as NSNumber,
                                  5 as NSNumber,
                                  10 as NSNumber,
                                  1 as NSNumber,
                                  10 as NSNumber]
    } else {
      renderer.strokeColor = UIColor(hex: "E7F161", alpha: 1)
      renderer.lineWidth = 8
    }
    return renderer
  }
  
  // - Tag: renderer_needs_display
  func displayNewBreadcrumbOnMap(_ newLocation: CLLocation) {
    /**
     If the `BreadcrumbPath` model object determines that the current location moves far enough from the previous location,
     use the returned updateRect to redraw just the changed area.
     */
    let result = breadcrumbs.addLocation(newLocation)
    
    /**
     If the `BreadcrumbPath` model object sucessfully adds the location to the path,
     update the rendering of the path to include the new location.
     */
    if result.locationAdded {
      // Compute the currently visible map zoom scale.
      let currentZoomScale = mapView.bounds.size.width / mapView.visibleMapRect.size.width
      
      /**
       Find out the line width at this zoom scale and outset the `pathBounds` by that amount to ensure the full line width draws.
       This covers situations where the new location is right on the edge of the provided `pathBounds`, and only part of the line width
       is within the bounds.
       */
      let lineWidth = MKRoadWidthAtZoomScale(currentZoomScale)
      var areaToRedisplay = breadcrumbs.pathBounds
      areaToRedisplay = areaToRedisplay.insetBy(dx: -lineWidth, dy: -lineWidth)
      
      /**
       Tell the overlay view to update just the changed area, including the area that the line width covers.
       Use `setNeedsDisplay(_:)` to only redraw the changed area of a breadcrumb overlay. For this sample,
       the changed area includes the entire overlay because if the app was recently in the background, the breadcrumb path
       that's visible when the app returns to the foreground might change significantly.
       
       In general, avoid calling `setNeedsDisplay()` on the overlay renderer without a map rectangle, as that may cause a render
       pass for the entire visible map, only some of which may contain updated data in the overlay.
       
       To avoid an expensive operation, call `setNeedsDisplay(_:)` instead of removing the overlay from the map and then immediately
       adding it back to trigger a render pass when the data is changing often. The rendering of an overlay after adding it to the
       map is not instantaneous, so removing and adding an overlay may cause a visual flicker as the system updates the map view
       without the overlay, and then updates it again with the overlay. This is especially true if the map is displaying more than
       one overlay or updating the overlay data often, such as on each location update.
       */
      breadcrumbPathRenderer?.setNeedsDisplay(areaToRedisplay)
    }
    
    if breadcrumbs.locations.count == 1 {
      // After determining the user's location, zoom the map to that location, and set the map to follow the user.
      let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
      mapView.setRegion(region, animated: true)
      mapView.setUserTrackingMode(.followWithHeading, animated: true)
    }
  }
}

extension MKMultiPoint {
  /// An array of all of the `UnsafeMutablePointer<MKMapPoint>` points in the shape converted to `[CLLocationCoordinate2D]`.
  var coordinates: [CLLocationCoordinate2D] {
    let pointData = points()
    return (0 ..< pointCount).map { pointData[$0].coordinate }
  }
}

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    let tolerance = 0.000_001
    let latitudeIsAlmostEqual = abs(lhs.latitude - rhs.latitude) < tolerance
    let longitudeIsAlmostEqual = abs(lhs.longitude - rhs.longitude) < tolerance
    
    return latitudeIsAlmostEqual && longitudeIsAlmostEqual
  }
}
