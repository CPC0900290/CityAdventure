//
//  EpisodeVC.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/1.
//

import Foundation
import UIKit
import MapKit

class EpisodeViewController: BaseMapViewController {
  // MARK: - Properties var
  let slideUpAnimationController = SlideUpAnimationController()
  var viewModel: EpisodeViewModel?
  private var currentTaskTag: Int?
  
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
  
  lazy var taskAButton = createTaskButton(title: "A", tag: 0)
  lazy var taskBButton = createTaskButton(title: "B", tag: 1)
  lazy var taskCButton = createTaskButton(title: "C", tag: 2)
  
  lazy var taskDetailView: TaskDetailView = {
    let taskDetailView = TaskDetailView()
    taskDetailView.titleLabel.text = "EpisodeTitle"
    taskDetailView.startButton.setTitle("繼續", for: .normal)
    taskDetailView.startButton.setTitle("請點擊側邊任務按鈕", for: .disabled)
    taskDetailView.startButton.setTitleColor(.darkGray, for: .disabled)
    taskDetailView.startButton.isEnabled = false
    taskDetailView.taskContentLabel.text = "點擊側邊任務按鈕，開始執行各別任務"
    taskDetailView.startButton.addTarget(self, action: #selector(startPlayingTask), for: .touchUpInside)
    taskDetailView.translatesAutoresizingMaskIntoConstraints = false
    return taskDetailView
  }()
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupTaskButton()
    setupNavItem()
    defaltTaskView()
    viewModel?.delegate = self
    mapView.showsUserLocation = true
    registerMapAnnotationViews()
    showAllAnnotations(self)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    taskDetailView.layer.cornerRadius = taskDetailView.frame.width / 30
    taskDetailView.clipsToBounds = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel?.configureTaskStatus()
  }
  
  // MARK: - Setup UI
  private func defaltTaskView() {
    taskDetailView.startButton.setTitle("繼續", for: .normal)
    taskDetailView.startButton.setTitle("請點擊側邊任務按鈕", for: .disabled)
    taskDetailView.startButton.setTitleColor(.darkGray, for: .disabled)
    taskDetailView.startButton.isEnabled = false
    taskDetailView.taskContentLabel.text = "點擊側邊任務按鈕，開始執行各別任務"
    switchButtonAlpha(taskDetailView.startButton)
  }
  
  private func switchButtonAlpha(_ sender: UIButton) {
    let alpha = sender.isEnabled ? 1 : 0.5
    sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(alpha)
  }
  
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
  
  private func setupTaskButton() {
    view.addSubview(taskAButton)
    view.addSubview(taskBButton)
    view.addSubview(taskCButton)
    NSLayoutConstraint.activate([
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
  
  // MARK: - Function
  private func createTaskButton(title: String, tag: Int) -> UIButton {
    let button = UIButton()
    
    button.setTitle(title, for: .normal)
    button.setTitleColor(.black, for: .normal)
    
    button.setTitle("", for: .disabled)
    button.setBackgroundImage(UIImage(systemName: "checkmark.square"), for: .disabled)
    
    button.tintColor = .darkGray
    button.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    button.layer.cornerRadius = 10
    button.tag = tag
    button.addTarget(self, action: #selector(showTasksAnnotation), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
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
  
  func configButtonStatus() {
    guard let taskStatus = viewModel?.taskStatus else { return }
      self.taskAButton.isEnabled = !taskStatus[0]
      self.taskBButton.isEnabled = !taskStatus[1]
      self.taskCButton.isEnabled = !taskStatus[2]
  }
  
  private func centerForTask(coordinate: CLLocationCoordinate2D) {
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
    self.mapView.setRegion(region, animated: true)
  }
  
  private func zoomInToTask(_ sender: UIButton) {
    guard let viewModel = viewModel,
          !viewModel.taskAnnotations.isEmpty else { return }
    let annotation = viewModel.taskAnnotations[sender.tag]
    displayOne(annotation)

    guard let tasks = viewModel.tasks,
          let property = tasks[sender.tag].features.first?.properties
    else { return }
    let coordinate = viewModel.taskCoordinates[sender.tag]
    let distance = Int(viewModel.getDistanceToTask(coordinate: coordinate))
    taskDetailView.titleLabel.text = property.title
    taskDetailView.taskContentLabel.text = property.content
    taskDetailView.taskDistanceLabel.text = "距離：\(distance) 公尺"
      if distance < 300 {
        taskDetailView.startButton.isEnabled = true
        switchButtonAlpha(taskDetailView.startButton)
      } else {
        taskDetailView.startButton.isEnabled = false
        switchButtonAlpha(taskDetailView.startButton)
      }
//    taskDetailView.startButton.isEnabled = true
//    switchButtonAlpha(taskDetailView.startButton)
    currentTaskTag = sender.tag
  }
  
  @objc private func showTasksAnnotation(_ sender: UIButton) {
    guard let currentTaskTag = currentTaskTag else {
      zoomInToTask(sender)
      return
    }
    if sender.tag == currentTaskTag {
      showAllTask(self)
    } else {
      zoomInToTask(sender)
    }
  }
  
  func showAllTask(_ sender: Any) {
    guard let viewModel = viewModel,
          let episode = viewModel.episode,
          !viewModel.taskAnnotations.isEmpty
    else { return }
    displayedAnnotations = viewModel.taskAnnotations
//    allAnnotations = viewModel.taskAnnotations
    taskDetailView.titleLabel.text = episode.title
    taskDetailView.taskContentLabel.text = "點擊側邊任務按鈕，開始執行各別任務"
    taskDetailView.taskDistanceLabel.text = ""
    centerMapForEpisode()
    taskDetailView.startButton.isEnabled = false
    switchButtonAlpha(taskDetailView.startButton)
    currentTaskTag = nil
  }
  
  private func displayOne(_ annotation: CustomAnnotation) {
    displayedAnnotations = [annotation]
    centerForTask(coordinate: annotation.coordinate)
  }
  
  func centerMapForEpisode() {
    guard let viewModel = viewModel,
          !viewModel.taskCoordinates.isEmpty
    else { return }
    let region = MKCoordinateRegion(coordinates: viewModel.taskCoordinates)
    mapView.setRegion(region, animated: true)
  }
  
  @objc func startPlayingTask() {
    guard let viewModel = viewModel,
          let tasks = viewModel.tasks,
          let currentTaskTag = currentTaskTag
    else { return }
    switch currentTaskTag {
    case 0:
      let taskVC = FirstTaskViewController()
      let taskContent = tasks[0].features[0].properties
      taskVC.task = taskContent
      taskVC.episodeForUser = viewModel.episode
      presentCustomViewController(viewController: taskVC)
    case 1:
      let taskVC = SecondTaskViewController()
      let taskContent = tasks[1]
//      taskVC.episode = viewModel.episode
      taskVC.secondTask = taskContent
      taskVC.modalPresentationStyle = .fullScreen
      self.present(taskVC, animated: true)
    case 2:
      let taskVC = ThirdTaskViewController()
      let taskContent = tasks[2].features[0].properties
      taskVC.task = taskContent
      taskVC.episodeForUser = viewModel.episode
      presentCustomViewController(viewController: taskVC)
    default:
      break
    }
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
}

extension EpisodeViewController: EpisodeModelProtocol {
  func updatedDataModels() {
    configButtonStatus()
  }
}

// MARK: - Animation UIViewControllerTransitioningDelegate
extension EpisodeViewController: UIViewControllerTransitioningDelegate {
  func presentCustomViewController(viewController: UIViewController) {
//    viewController.transitioningDelegate = self
    if let sheet = viewController.sheetPresentationController {
      sheet.detents = [.medium()]
    }
    present(viewController, animated: true, completion: nil)
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
