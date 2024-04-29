//
//  EpisodeDetailViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/27.
//
/* 
 TODO - UI Design
      - UI layout
      - set data to UI, Get episodeID & episode from HomeVC
      - create ViewModel - post episodeID to Profile if button clicked
      - Start Task Button logic, add episode to Profile & segue to EpisodeVC
 */

import Foundation
import UIKit
import MapKit

class EpisodeDetailViewController: UIViewController {
  
  // MARK: - Properties
  var episode: Episode?
  private var tasks: [LocationPath] = []
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
        mapView.addAnnotations(newAnnotations)
      }
//      centerMapOnSanFrancisco()
    }
  }
  
  lazy var taskDetailView: TaskDetailView = {
    let taskDetailView = TaskDetailView()
    taskDetailView.titleLabel.text = "EpisodeTitle"
    taskDetailView.taskContentLabel.text = "EpisodeDescription"
    taskDetailView.translatesAutoresizingMaskIntoConstraints = false
    return taskDetailView
  }()
  
  lazy var taskAButton: UIButton = {
    let button = UIButton()
    button.setTitle("A", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  lazy var taskBButton: UIButton = {
    let button = UIButton()
    button.setTitle("B", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.tintColor = .black
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  lazy var taskCButton: UIButton = {
    let button = UIButton()
    button.setTitle("C", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.tintColor = .black
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.showsUserLocation = true
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavItem()
    getTasksAndLocations()
    setupUI()
    registerMapAnnotationViews()
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
    // Doing
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
    mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotation.self))
  }
  
  // MARK: - Functions
  private func getTasksAndLocations() {
    guard let episode = episode else { return }
    viewModel.fetchTask(episode: episode) { locationPaths in
      self.tasks = locationPaths
      self.viewModel.fetchAnnotation(locationPaths: self.tasks) { annotations in
        self.allAnnotations = annotations
      }
    }
  }
  
  private func displayOne(_ annotationType: AnyClass) {
    let annotation = allAnnotations?.first { (annotation) -> Bool in
      return annotation.isKind(of: annotationType)
    }
    
    if let oneAnnotation = annotation {
      displayedAnnotations = [oneAnnotation]
    } else {
      displayedAnnotations = []
    }
  }
  
  @objc private func showTasksAnnotation(_ sender: Any) {
    
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
