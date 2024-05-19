//
//  EpisodeIntroViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/27.
//

import Foundation
import UIKit
import MapKit

class EpisodeIntroViewController: BaseMapViewController {
  // MARK: - Properties
  var viewModel: EpisodeIntroViewModel?
  
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
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavItem()
    setupUI()
//    detectTaskButton()
    registerMapAnnotationViews()
    showAllAnnotations(self)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    taskDetailView.layer.cornerRadius = taskDetailView.frame.width / 30
    taskDetailView.clipsToBounds = true
  }
  
  // MARK: - UI Setup
  func setupUI() {
    view.addSubview(mapView)
    view.addSubview(taskDetailView)
    
    NSLayoutConstraint.activate([
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      taskDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
      taskDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
      taskDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
    ])
  }
  
  private func registerMapAnnotationViews() {
    mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotation.self))
  }
  
  // MARK: - Functions
  // EpisodeIntro
  @objc func startPlaying() {
//    detectTaskButton()
    guard let viewModel = viewModel,
          let episode = viewModel.episode
    else { return }
    
    let adventuringEpisode = AdventuringEpisode(episodeID: episode.id, taskStatus: [false, false, false])
    viewModel.updateUserPlayingList(adventuringEpisode)
    let episodeVC = EpisodeViewController()
    episodeVC.viewModel = EpisodeViewModel(episode: episode)
    self.navigationController?.pushViewController(episodeVC, animated: false)
  }
  
  @objc func showAllAnnotations(_ snder: Any) {
    guard let viewModel = viewModel,
          let episode = viewModel.episode,
          !viewModel.taskAnnotations.isEmpty
    else { return }
    displayedAnnotations = viewModel.taskAnnotations
    taskDetailView.titleLabel.text = episode.title
    taskDetailView.taskContentLabel.text = episode.content
    taskDetailView.taskDistanceLabel.text = ""
    centerMapForEpisode()
  }
  
  func centerMapForEpisode() {
    guard let viewModel = viewModel,
          !viewModel.taskCoordinates.isEmpty
    else { return }
    let region = MKCoordinateRegion(coordinates: viewModel.taskCoordinates)
    mapView.setRegion(region, animated: true)
  }
  
  @objc func lastPage() {
    self.navigationController?.popToRootViewController(animated: true)
    guard let controllers = self.navigationController?.viewControllers else { return }
    for controller in controllers {
      if let homeVC = controller as? HomeViewController {
        homeVC.viewModel.fetchProfile {
          homeVC.viewModel.fetchAdventuringEpisodes { }
        }
        self.navigationController?.popToViewController(homeVC, animated: true)
      }
    }
  }
  func setupNavItem() {
    self.title = viewModel?.episode?.title
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
