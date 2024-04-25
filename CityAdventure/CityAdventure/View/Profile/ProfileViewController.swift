//
//  ProfileViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/25.
//

import Foundation
import UIKit

enum ProfileSection: String, CaseIterable {
  case main
}

enum ProfileItem: Hashable {
  
}

class ProfileViewController: UIViewController {
  // MARK: - Properties
  private var dataSource: UICollectionViewDiffableDataSource<ProfileSection, ProfileItem>!
  private var sectionArray = ProfileSection.allCases
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    setupNavItem()
    setupUI()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    avatarImgView.layer.cornerRadius = avatarImgView.frame.width / 2
  }
  
  // MARK: - UI Setup
  lazy var avatarImgView: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var userNameLabel: UILabel = {
    let label = UILabel()
    label.text = "User"
    label.font = UIFont(name: "PingFang TC", size: 25)
    label.font = UIFont.boldSystemFont(ofSize: 25)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var userTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "UserTitle"
    label.font = UIFont(name: "PingFang TC", size: 15)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var separateView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView()
    collectionView.delegate = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
  
  private func setupUI() {
    view.addSubview(avatarImgView)
    view.addSubview(userNameLabel)
    view.addSubview(userTitleLabel)
    view.addSubview(separateView)
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      avatarImgView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
      avatarImgView.heightAnchor.constraint(equalTo: avatarImgView.widthAnchor, multiplier: 1),
      avatarImgView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      avatarImgView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
      
      userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      userNameLabel.topAnchor.constraint(equalTo: avatarImgView.bottomAnchor, constant: 15),
      
      userTitleLabel.centerXAnchor.constraint(equalTo: userNameLabel.centerXAnchor),
      userTitleLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
      
      separateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      separateView.topAnchor.constraint(equalTo: userTitleLabel.bottomAnchor, constant: 10),
      separateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      separateView.heightAnchor.constraint(equalToConstant: 1),
      
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.topAnchor.constraint(equalTo: separateView.bottomAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }
  
  func setupNavItem() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationItem.largeTitleDisplayMode = .always
    self.title = "個人檔案"
    let navBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(lastPage))
    navBarItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = navBarItem
  }
  
  private func setupCVLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { sectionNum, _ in
      let sections = self.sectionArray[sectionNum]
      switch sections {
      case .main: return self.zeroLayoutSection()
      }
    }
  }
  
  private func zeroLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize) // Whithout badge
    item.contentInsets = .init(top: 5, leading: 0, bottom: 15, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension:.fractionalWidth(0.3))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    return section
  }
  
  // MARK: - Function
  @objc func lastPage() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension HomeViewController {
  typealias ProfileDataSource = UICollectionViewDiffableDataSource<ProfileSection, ProfileItem>
  private func configDataSource() {
    
  }
  
  private func configSnapshot() {
    var currentSnapshot = NSDiffableDataSourceSnapshot<ProfileSection, ProfileItem>()
    
  }
}

extension ProfileViewController: UICollectionViewDelegate {
  
}
