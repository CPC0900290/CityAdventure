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
    setupNavItem()
  }
  
  @objc func lastPage() {
    self.navigationController?.popViewController(animated: true)
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
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  func setupNavItem() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationItem.largeTitleDisplayMode = .always
    self.title = episodeForUser?.title
    let navBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(lastPage))
    navBarItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = navBarItem
  }
  
  func setupUI() {
    view.addSubview(taskView)
    taskView.addSubview(backgroundMaterial)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      taskView.topAnchor.constraint(equalTo: view.topAnchor),
      taskView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      taskView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      backgroundMaterial.leadingAnchor.constraint(equalTo: taskView.leadingAnchor),
      backgroundMaterial.topAnchor.constraint(equalTo: taskView.topAnchor),
      backgroundMaterial.trailingAnchor.constraint(equalTo: taskView.trailingAnchor),
      backgroundMaterial.bottomAnchor.constraint(equalTo: taskView.bottomAnchor)
    ])
  }
}
