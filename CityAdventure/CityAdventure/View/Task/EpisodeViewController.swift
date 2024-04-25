//
//  ViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/10.
//
// TODO: 修正DraggableMarkerView 的消失時間點，只有TaskVC, FirstTaskVC, ThirdTaskVC 需要出現，SpeechVC 要修正他消失。

import UIKit

class EpisodeViewController: UIViewController {
  
  let viewModel = TaskViewModel()
  private var tableView = UITableView()
  var episodeList: [Episode] = []
  var episodeForUser: Episode?
  var episodeID: String?
  var taskList: [Properties] = []
  var taskStatus: [Bool] = []
  let uploadEpisode = UploadEpisode()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
//    uploadEpisode.postEpisode()
    //    FireStoreManager.shared.postEpisode()
    //    FireStoreManager.shared.fetchTask()
    view.backgroundColor = .black
    setupUI()
    setupTableView()
    setupMarkerView()
    guard let episodeID = episodeID else { return }
    self.viewModel.fetchEpisode(id: episodeID) { episode in
      self.episodeForUser = episode
      self.viewModel.fetchTask(episode: episode) { tasks in
        self.taskList = tasks
      }
      self.tableView.reloadData()
    }
    setupNavItem()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    taskView.layer.cornerRadius = taskView.frame.width / 10
    tableView.layer.cornerRadius = tableView.frame.width / 10
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
  
  func setupUI() {
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
    tableView.isScrollEnabled = false
    tableView.backgroundColor = .white
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = tableView.estimatedRowHeight
    tableView.estimatedRowHeight = 100
    tableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "TaskCell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: taskView.leadingAnchor),
      tableView.topAnchor.constraint(equalTo: taskView.topAnchor),
      tableView.trailingAnchor.constraint(equalTo: taskView.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: taskView.bottomAnchor)
    ])
  }
  
  private func setupMarkerView() {
    DraggableMarkerManager.shared.showMarker(in: self) {
      let mapVC = MapViewController()
      mapVC.modalPresentationStyle = .automatic
      mapVC.tasks = self.taskList
      self.present(mapVC, animated: true)
    }
  }
}

extension EpisodeViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    taskView.frame.height / 3
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let episode = episodeForUser else {
      print("TaskVC NumberOfRowInSection got 0, episodeForUser is nil")
      return 0
    }
    return episode.tasks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as? TaskViewCell,
          let episode = episodeForUser
    else {
      return UITableViewCell()
    }
    viewModel.fetchTask(episode: episode) { task in
      cell.taskLabel.text = task[indexPath.row].title
      cell.taskTitleLabel.text = task[indexPath.row].content
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let episode = episodeForUser else { return }
    viewModel.fetchTask(episode: episode) { _ in
      switch indexPath.row {
      case 0:
        let taskVC = FirstTaskViewController()
        taskVC.setupNavItem()
        taskVC.task = self.taskList[0]
        taskVC.navigationItem.title = episode.title
        self.navigationController?.pushViewController(taskVC, animated: true)
      case 1:
        let taskVC = SecondTaskViewController()
        taskVC.setupNavItem()
        self.navigationController?.pushViewController(taskVC, animated: true)
      case 2:
        let taskVC = ThirdTaskViewController()
        taskVC.setupNavItem()
        taskVC.navigationItem.title = episode.title
        DraggableMarkerManager.shared.hideMarker()
        self.navigationController?.pushViewController(taskVC, animated: true)
      default:
        print("task out of range")
      }
    }
  }
}
