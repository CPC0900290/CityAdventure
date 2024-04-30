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
  private var tasks: [TaskLocations] = []
  private var viewModel = EpisodeDetailViewModel()
  private var locationManager: CLLocationManager?
  private var allAnnotations: [MKAnnotation]?
  
  private var displayedAnnotations: [MKAnnotation]? {
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
  
  lazy var taskAButton: UIButton = {
    let button = UIButton()
    button.setTitle("A", for: .normal)
    button.setTitleColor(.black, for: .selected)
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.tag = 0
    button.titleLabel?.highlightedTextColor = .black
    button.addTarget(self, action: #selector(showTasksAnnotation), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  lazy var taskBButton: UIButton = {
    let button = UIButton()
    button.setTitle("B", for: .normal)
    button.setTitleColor(.black, for: .selected)
    button.tintColor = .black
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.tag = 1
    button.titleLabel?.highlightedTextColor = .black
    button.addTarget(self, action: #selector(showTasksAnnotation), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  lazy var taskCButton: UIButton = {
    let button = UIButton()
    button.setTitle("C", for: .normal)
    button.setTitleColor(.black, for: .selected)
    button.tintColor = .black
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.tag = 2
    button.titleLabel?.highlightedTextColor = .black
    button.addTarget(self, action: #selector(showTasksAnnotation), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.showsUserLocation = true
    map.delegate = self
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavItem()
//    viewModel.setupLocationManager(self)
    setupUI()
    registerMapAnnotationViews()
    getTasksAndLocations()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    taskDetailView.layer.cornerRadius = taskDetailView.frame.width / 50
  }
  
  // MARK: - UI Setup
  
  private func setupUI() {
    view.addSubview(mapView)
    view.addSubview(taskDetailView)
    view.addSubview(taskAButton)
    view.addSubview(taskBButton)
    view.addSubview(taskCButton)
    
    NSLayoutConstraint.activate([
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      taskDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      taskDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      taskDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      taskDetailView.heightAnchor.constraint(equalToConstant: 200),
      
      taskAButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      taskAButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
      taskAButton.widthAnchor.constraint(equalTo: taskAButton.heightAnchor),
      taskAButton.widthAnchor.constraint(equalToConstant: 50),
      
      taskBButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      taskBButton.topAnchor.constraint(equalTo: taskAButton.bottomAnchor, constant: 20),
      taskBButton.widthAnchor.constraint(equalTo: taskBButton.heightAnchor),
      taskBButton.widthAnchor.constraint(equalToConstant: 50),
      
      taskCButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      taskCButton.topAnchor.constraint(equalTo: taskBButton.bottomAnchor, constant: 20),
      taskCButton.widthAnchor.constraint(equalTo: taskCButton.heightAnchor),
      taskCButton.widthAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  private func registerMapAnnotationViews() {
    mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotation.self))
  }
  
  // MARK: - Functions
  @objc private func startPlaying() {
    guard let episode = episode,
          let user = user
    else { return }
    let adventuringEpisode = AdventuringEpisode(episodeID: episode.id, taskStatus: [false, false, false])
    viewModel.updateUserPlayingList(user: user, adventuringEpisode)
    let episodeVC = EpisodeViewController()
    episodeVC.episodeForUser = episode
    self.navigationController?.pushViewController(episodeVC, animated: true)
  }
  
  private func centerMapForEpisode() {
    viewModel.fetchCoordinate(taskLocations: tasks) { coordinates in
      let region = MKCoordinateRegion(coordinates: coordinates)
      self.mapView.setRegion(region, animated: true)
    }
  }
  
  private func centerForTask(coordinate: CLLocationCoordinate2D) {
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
    self.mapView.setRegion(region, animated: true)
  }
  
  private func getTasksAndLocations() {
    guard let episode = episode else { return }
    viewModel.fetchTask(episode: episode) { taskLocations in
      self.tasks = taskLocations
      self.viewModel.fetchAnnotation(taskLocations: self.tasks) { annotations in
        self.allAnnotations = annotations
        self.showAllAnnotations(self)
      }
    }
  }
  
  private func displayOne(_ annotation: CustomAnnotation) {
    displayedAnnotations = [annotation]
    centerForTask(coordinate: annotation.coordinate)
  }
  
  @objc private func showTasksAnnotation(_ sender: UIButton) {
    sender.isSelected.toggle()
    resetButtonSelected(sender)
    switch sender.isSelected {
    case true:
      guard let allAnnotations = allAnnotations as? [CustomAnnotation] else { return }
      displayOne(allAnnotations[sender.tag])
      
      guard let property = tasks[sender.tag].features.first?.properties else { return }
      taskDetailView.titleLabel.text = property.title
      taskDetailView.taskContentLabel.text = property.content
    case false:
      displayedAnnotations = allAnnotations
      centerMapForEpisode()
    }
  }
  
  private func resetButtonSelected(_ sender: UIButton) {
    switch sender.tag {
    case 0:
      taskBButton.isSelected = false
      taskCButton.isSelected = false
    case 1:
      taskAButton.isSelected = false
      taskCButton.isSelected = false
    case 2:
      taskAButton.isSelected = false
      taskBButton.isSelected = false
    default:
      print("Button tag is out of range")
    }
  }
  
  @objc private func showAllAnnotations(_ snder: Any) {
    displayedAnnotations = allAnnotations
    centerMapForEpisode()
  }
  
  @objc func lastPage() {
    self.navigationController?.popViewController(animated: true)
  }
  
  func setupNavItem() {
    self.title = episode?.title
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
