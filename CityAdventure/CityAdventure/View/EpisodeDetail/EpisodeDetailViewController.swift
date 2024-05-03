//
//  EpisodeDetailViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/27.
//

import Foundation
import UIKit
import MapKit

class EpisodeDetailViewController: UIViewController {
  
  // MARK: - Properties
  var episode: Episode?
  var user: Profile?
  var tasks: [TaskLocations] = []
  var viewModel = EpisodeDetailViewModel()
  var allAnnotations: [MKAnnotation]?
  
  var displayedAnnotations: [MKAnnotation]? {
    willSet {
      if let currentAnnotations = displayedAnnotations {
        mapView.removeAnnotations(currentAnnotations)
      }
    }
    didSet {
      if let newAnnotations = displayedAnnotations {
        DispatchQueue.main.async {
          self.mapView.addAnnotations(newAnnotations)
        }
      }
    }
  }
  
  lazy var taskDetailView: TaskDetailView = {
    let taskDetailView = TaskDetailView()
    taskDetailView.titleLabel.text = "EpisodeTitle"
    taskDetailView.taskContentLabel.text = "EpisodeDescription"
    taskDetailView.startButton.addTarget(self, action: #selector(startPlaying), for: .touchUpInside)
    taskDetailView.translatesAutoresizingMaskIntoConstraints = false
    return taskDetailView
  }()
  
  lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.showsUserLocation = false
    map.delegate = self
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavItem()
    setupUI()
    registerMapAnnotationViews()
    guard let episode = episode else { return }
    viewModel.getData(episode: episode)
    showAllAnnotations(self)
    viewModel.setupLocationManager(self)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    taskDetailView.layer.cornerRadius = taskDetailView.frame.width / 50
  }
  
  // MARK: - UI Setup
  
  private func setupUI() {
    view.addSubview(mapView)
    view.addSubview(taskDetailView)
    
    NSLayoutConstraint.activate([
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      taskDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      taskDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      taskDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func registerMapAnnotationViews() {
    mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotation.self))
  }
  
  // MARK: - Functions
  // UI 接收使用者指令
  @objc func startPlaying() {
    guard let episode = episode else { return }
    let adventuringEpisode = AdventuringEpisode(episodeID: episode.id, taskStatus: [false, false, false])
    viewModel.updateUserPlayingList(adventuringEpisode)
    let episodeVC = EpisodeViewController()
    episodeVC.episode = episode
    self.navigationController?.pushViewController(episodeVC, animated: false)
  }
  // UI 顯示畫面
  @objc func showAllAnnotations(_ snder: Any) {
    guard let episode = episode,
          !viewModel.taskAnnotations.isEmpty
    else { return }
    displayedAnnotations = viewModel.taskAnnotations
    allAnnotations = viewModel.taskAnnotations
    taskDetailView.titleLabel.text = episode.title
    taskDetailView.taskContentLabel.text = episode.content
    taskDetailView.taskDistanceLabel.text = ""
    centerMapForEpisode()
  }
  
  private func centerMapForEpisode() {
    guard !viewModel.taskCoordinates.isEmpty else { return }
    let region = MKCoordinateRegion(coordinates: viewModel.taskCoordinates)
    mapView.setRegion(region, animated: true)
  }
  
  @objc func lastPage() {
    self.navigationController?.popToRootViewController(animated: true)
//    self.navigationController?.popViewController(animated: true)
  }
  
  func setupNavItem() {
    self.title = episode?.title
    self.navigationController?.navigationItem.largeTitleDisplayMode = .never
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.navigationBar.backgroundColor = .clear
    let navBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), 
                                     style: .plain,
                                     target: self,
                                     action: #selector(lastPage))
    navBarItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = navBarItem
  }
}

// MARK: - MKMapViewDelegate
extension EpisodeDetailViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    guard !annotation.isKind(of: MKUserLocation.self) else {
      return nil
    }
    
    var annotationView: MKAnnotationView?
    
    if let annotation = annotation as? CustomAnnotation {
      annotationView = setupCustomAnnotationView(for: annotation, on: mapView)
    }
    
    return annotationView
  }
  
  private func setupCustomAnnotationView(for annotation: CustomAnnotation, on mapView: MKMapView) -> MKAnnotationView {
    let identifier = NSStringFromClass(CustomAnnotation.self)
    let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
    if let markerAnnotationView = view as? MKMarkerAnnotationView {
      markerAnnotationView.animatesWhenAdded = true
      markerAnnotationView.canShowCallout = true
      markerAnnotationView.markerTintColor = UIColor(hex: "E7F161", alpha: 1)
    }
    return view
  }
}
// MARK: - CLLocationManagerDelegate
extension EpisodeDetailViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    viewModel.checkLocationAuthorization(mapView: mapView)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
