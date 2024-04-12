//
//  ViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/10.
//

import UIKit

class TaskViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    FireStoreManager.shared.makeJson()
//    FireStoreManager.shared.fetchTask()
    view.backgroundColor = .black
  }
  lazy var taskView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
//    view.addSubview()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
}
