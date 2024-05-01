//
//  ViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/10.
//
// TODO: 繼承EpisodeDetailVC

import UIKit

class EpisodeViewController: UIViewController {
  
  let viewModel = TaskViewModel()
  private var tableView = UITableView()
  var episodeList: [Episode] = []
  var episodeForUser: Episode?
  var episodeID: String?
  var taskList: [Properties] = []
  var taskStatus: [Bool] = []
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    //    FireStoreManager.shared.postEpisode()
    //    FireStoreManager.shared.fetchTask()
    view.backgroundColor = .black
    setupUI()
    guard let episode = episodeForUser else { return }
    self.viewModel.fetchTask(episode: episode) { tasks in
      self.taskList = tasks
    }
    setupNavItem()
  }
  
  @objc func lastPage() {
    self.navigationController?.popViewController(animated: true)
  }
  
  // MARK: - UI Setup
  func setupNavItem() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationItem.largeTitleDisplayMode = .always
    self.title = episodeForUser?.title
    let navBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(lastPage))
    navBarItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = navBarItem
  }
  
  lazy var taskView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
//  lazy var locationALabel: UILabel = {
//    let label = UILabel()
//    label.text = "LocationA"
//    label.font = UIFont(name: "PingFang TC", size: 18)
//    label.textColor = UIColor(hex: "E7F161", alpha: 1)
//    label.translatesAutoresizingMaskIntoConstraints = false
//    return label
//  }()
//  
//  lazy var locationBLabel: UILabel = {
//    let label = UILabel()
//    label.text = "LocationB"
//    label.font = UIFont(name: "PingFang TC", size: 18)
//    label.textColor = UIColor(hex: "E7F161", alpha: 1)
//    label.translatesAutoresizingMaskIntoConstraints = false
//    return label
//  }()
  
  func setupUI() {
    view.addSubview(taskView)
//    view.addSubview(locationALabel)
//    view.addSubview(locationBLabel)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      taskView.topAnchor.constraint(equalTo: view.topAnchor),
      taskView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      taskView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      
//      locationALabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
//      locationALabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
//      
//      locationBLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
//      locationBLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
    ])
  }
}

extension UIViewController {
  
  func backToRoot(completion: (() -> Void)? = nil) {
    if presentingViewController != nil {
      let superVC = presentingViewController
      dismiss(animated: false, completion: nil)
      superVC?.backToRoot(completion: completion)
      return
    }
//    
//    if let tabbarVC = self as? UITabBarController {
//      tabbarVC.selectedViewController?.backToRoot(completion: completion)
//      return
//    }
//    
//    if let navigateVC = self as? UINavigationController {
//      navigateVC.popToRootViewController(animated: false)
//    }
    
    completion?()
  }
}
