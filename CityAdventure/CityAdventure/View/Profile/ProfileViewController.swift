//
//  ProfileViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/25.
//

import Foundation
import UIKit
import Kingfisher

enum ProfileSection: String, CaseIterable {
  case main
}

class ProfileViewController: UIViewController {
  // MARK: - Properties
  private var dataSource: UICollectionViewDiffableDataSource<ProfileSection, String>!
  var userProfile: Profile?
  var finishedEpisodes: [Episode]?
  private let viewModel = ProfileViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    fetchData()
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
    let layout = setupCVLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .black
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
    collectionView.register(UINib(nibName: "PostCell", bundle: nil),
                            forCellWithReuseIdentifier: "PostCell")
    configDataSource()
    configSnapshot()
    collectionView.collectionViewLayout = setupCVLayout()
    collectionView.delegate = self
  }
  
  func setupNavItem() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationItem.largeTitleDisplayMode = .always
    self.title = "個人檔案"
    let navBarItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), 
                                     style: .plain,
                                     target: self,
                                     action: #selector(lastPage))
    let rightNavBarItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(handleAccount))
    navBarItem.tintColor = UIColor.white
    rightNavBarItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = navBarItem
    navigationItem.rightBarButtonItem = rightNavBarItem
  }
  
  private func setupCVLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                           heightDimension: .estimated(150))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   repeatingSubitem: item,
                                                   count: 2)
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0)
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  // MARK: - Function
  @objc private func handleAccount() {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let logoutAction = UIAlertAction(title: "登出", style: .default) { _ in
      print("didPress report abuse")
      self.viewModel.logout()
    }
    
    let deleteAction = UIAlertAction(title: "刪除帳號", style: .destructive) { _ in
      print("didPress block")
      Task {
        await self.viewModel.deleteAccount()
      }
    }
    
    let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
      print("didPress cancel")
    }
    actionSheet.addAction(logoutAction)
    actionSheet.addAction(deleteAction)
    actionSheet.addAction(cancelAction)
    // Present the controller
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  @objc func lastPage() {
    self.navigationController?.popViewController(animated: true)
  }
  
  func fetchData() {
    guard let profile = userProfile else { return }
    for finishedTaskID in profile.finishedEpisodeID {
      viewModel.fetchEpisode(id: finishedTaskID) { episode in
        self.finishedEpisodes?.append(episode)
      }
    }
    userNameLabel.text = profile.nickName
    userTitleLabel.text = profile.titleName
    avatarImgView.image = UIImage(systemName: profile.avatar)
  }
}

extension ProfileViewController {
  typealias ProfileDataSource = UICollectionViewDiffableDataSource<ProfileSection, String>
  private func configDataSource() {
    dataSource = ProfileDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, _ in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.identifier, for: indexPath) as? PostCell,
            let episodes = self.finishedEpisodes
      else {
        print("ProfileVC PostCell fail to init")
        return UICollectionViewCell()
      }
      cell.update(with: episodes[indexPath.row])
      return cell
    })
  }
  
  private func configSnapshot() {
    var currentSnapshot = NSDiffableDataSourceSnapshot<ProfileSection, String>()
    guard let finishedEpisodes = userProfile?.finishedEpisodeID else { return }
    currentSnapshot.appendSections(ProfileSection.allCases)
    currentSnapshot.appendItems(finishedEpisodes, toSection: .main)
    dataSource.apply(currentSnapshot)
  }
}

extension ProfileViewController: UICollectionViewDelegate {
  
}
