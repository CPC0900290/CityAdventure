//
//  ViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/10.
//

import UIKit

class TaskViewController: UIViewController {
  
  private let viewModel = TaskViewModel()
  private var tableView = UITableView()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
//    FireStoreManager.shared.makeJson()
//    FireStoreManager.shared.fetchTask()
    view.backgroundColor = .black
    setupUI()
    setupTableView()
    setupMarkerView()
    viewModel.fetchWholeData { episodeList in
      print("VC get the episodeList from viewModel")
      print(episodeList)
    }
  }
  
  // MARK: - UI Setup
  lazy var taskView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var locationALabel: UILabel = {
    let label = UILabel()
    label.text = "LocationA"
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.textColor = UIColor(hex: "E7F161", alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var locationBLabel: UILabel = {
    let label = UILabel()
    label.text = "LocationB"
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.textColor = UIColor(hex: "E7F161", alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private func setupUI() {
    view.addSubview(taskView)
    view.addSubview(locationALabel)
    view.addSubview(locationBLabel)
    NSLayoutConstraint.activate([
      taskView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
      taskView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
      taskView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
      taskView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
      
      locationALabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
      locationALabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
      
      locationBLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
      locationBLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
    ])
  }
  
  func setupTableView() {
    taskView.addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = 0
    tableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "TaskCell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: taskView.leadingAnchor),
      tableView.topAnchor.constraint(equalTo: taskView.topAnchor),
      tableView.trailingAnchor.constraint(equalTo: taskView.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: taskView.bottomAnchor)
    ])
  }
  
  func setupMarkerView() {
    DraggableMarkerManager.shared.showMarker(in: self) {
      let mapVC = MapViewController()
      mapVC.modalPresentationStyle = .automatic
//      self.show(mapVC, sender: nil)
      self.present(mapVC, animated: true)
    }
  }
}

extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as? TaskViewCell else { return UITableViewCell() }
    cell.taskLabel.text = "任務一"
    cell.taskTitleLabel.text = "請至blalbalalbalblalab"
    return cell
  }
}
