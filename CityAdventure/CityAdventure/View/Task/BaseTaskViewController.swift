//
//  ViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/10.
//

import UIKit

class BaseTaskViewController: UIViewController {
  
  let viewModel = TaskViewModel()
  var episodeList: [Episode] = []
  var episodeForUser: Episode?
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    setupUI()
//    guard let episode = episodeForUser else { return }
//    self.viewModel.fetchTask(episode: episode) { tasks in
//      self.taskList = tasks
//    }
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
  
  func setupUI() {
    view.addSubview(taskView)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      taskView.topAnchor.constraint(equalTo: view.topAnchor),
      taskView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      taskView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
