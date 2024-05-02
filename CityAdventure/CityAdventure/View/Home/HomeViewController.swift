//
//  HomeViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/21.
//

import Foundation
import UIKit
import Kingfisher
import FirebaseAuth

class HomeViewController: UIViewController {
  // MARK: - Property var
  let uploadEpisode = UploadEpisode()
  private let userDefault = UserDefaults()
  private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  private var sectionArray: [Section] = Section.allCases
  private let viewModel = HomeViewModel()
  private var episodeIDList: [String] = []
  private var episodeList: [Episode] = []
  private var areaEpisodes: [Episode] = []
  private var adventuringEpisodes: [Episode] = []
  private var profile: Profile?
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    //    uploadEpisode.postProfile()
    //    uploadEpisode.postEpisode()
    fetchUser()
    fetchData()
    setupNavigation()
  }
  
  // MARK: - UI Setup
  lazy var collectionView: UICollectionView = {
    let layout = setupCVLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
  
  private func setupUI() {
    view.addSubview(collectionView)
    view.backgroundColor = .black
    collectionView.backgroundColor = .black
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
    collectionView.register(TitleSupplementaryView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    collectionView.register(UINib(nibName: "ProfileCell", bundle: nil),
                            forCellWithReuseIdentifier: "ProfileCell")
    collectionView.register(UINib(nibName: "AdventuringTaskCell", bundle: nil),
                            forCellWithReuseIdentifier: "AdventuringTaskCell")
    collectionView.register(UINib(nibName: "ExploreAreaCell", bundle: nil),
                            forCellWithReuseIdentifier: "ExploreAreaCell")
    collectionView.register(UINib(nibName: "EpisodeCell", bundle: nil),
                            forCellWithReuseIdentifier: "EpisodeCell")
    configDataSource()
    configSnapshot()
    collectionView.collectionViewLayout = setupCVLayout()
    collectionView.delegate = self
  }
  
  private func setupNavigation() {
    self.title = "城市探險"
    navigationController?.navigationItem.largeTitleDisplayMode = .never
  }
  
  // MARK: - Function
  private func fetchData() {
    viewModel.fetchEpisodeList { idList in
      self.episodeIDList = idList
      let dispatchGroup = DispatchGroup()
      
      for episodeID in idList {
        dispatchGroup.enter()
        self.viewModel.fetchEpisode(id: episodeID) { episode in
          self.episodeList.append(episode)
          if episode.area == "台北" {
            self.areaEpisodes.append(episode)
          }
          dispatchGroup.leave()
        }
      }
      dispatchGroup.notify(queue: .main) {
        self.setupUI()
      }
    }
  }
  
  private func fetchUserPlayingData() {
    guard let profile = profile else { return }
    guard !profile.adventuringEpisode.isEmpty else { return }
    for episdoe in profile.adventuringEpisode {
      let id = episdoe.episodeID
      viewModel.fetchEpisode(id: id) { episode in
        self.adventuringEpisodes.append(episode)
      }
    }
  }
  
  @objc func segueToEpisode(_ sender: UIButton) {
    guard let profile = profile else { return }
    guard !profile.adventuringEpisode.isEmpty else { return }
    let episodeVC = EpisodeViewController()
    episodeVC.episode = adventuringEpisodes[sender.tag]
    episodeVC.user = profile
    navigationController?.pushViewController(episodeVC, animated: true)
  }
  
  private func fetchUser() {
    // 判斷是否已經登入 -是：就不顯示loginVC -否：顯示loginVC
    // 如果沒登入過，要sign in with apple後才會dismiss這個ViewController
    guard let user = Auth.auth().currentUser else { return }
    viewModel.fetchProfile(uid: user.uid) { profile in
      self.profile = profile
      self.fetchUserPlayingData()
    }
  }
}

// MARK: - UICollectionViewLayout
extension HomeViewController {
  
  private func setupCVLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { sectionNum, _ in
      let sections = self.sectionArray[sectionNum]
      switch sections {
      case .profile: return self.zeroLayoutSection()
      case .doingEpisode: return self.firstLayoutSection()
      case .areaEpisode: return self.secondLayoutSection()
      case .episodeList: return self.thirdLayoutSection()
      }
    }
  }
  
  private func zeroLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize) // Whithout badge
    item.contentInsets = .init(top: 5, leading: 0, bottom: 15, trailing: 0)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                           heightDimension:.fractionalWidth(0.3))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitems: [item])
    group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    return section
  }
  
  private func firstLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize) // Whithout badge
    item.contentInsets = .init(top: 15, leading: 0, bottom: 15, trailing: 0)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                           heightDimension:.fractionalWidth(0.8))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitems: [item])
    group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    return section
  }
  
  private func secondLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 15, leading: 0, bottom: 15, trailing: 15)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.32),
                                           heightDimension: .estimated(200))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets.leading = 15
    section.orthogonalScrollingBehavior = .continuous
    section.boundarySupplementaryItems = [
    NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension:.fractionalWidth(1),
                                                                  heightDimension: .estimated(44)),
                                                elementKind: UICollectionView.elementKindSectionHeader,
                                                alignment:.topLeading)
    ]
    return section
  }
  
  private func thirdLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalWidth(0.7))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   repeatingSubitem: item,
                                                   count: 1)
    group.interItemSpacing = .fixed(CGFloat(10))
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
    section.boundarySupplementaryItems = [
      NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension:.fractionalWidth(1),
                                                                    heightDimension: .estimated(44)),
                                                  elementKind: UICollectionView.elementKindSectionHeader,
                                                  alignment:.topLeading)
    ]
    return section
  }
}

// MARK: - UICollecitonViewDiffableDataSource
extension HomeViewController {
  typealias EpisodeDataSource = UICollectionViewDiffableDataSource<Section, Item>
  private func configDataSource() {
    dataSource = EpisodeDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, _ in
      let section = self.sectionArray[indexPath.section]
      switch section {
      case .profile:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell,
              let profile = self.profile
        else { return UICollectionViewCell() }
        cell.update(with: profile)
        return cell
        
      case .doingEpisode:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdventuringTaskCell.identifier, for: indexPath) as? AdventuringTaskCell else { return UICollectionViewCell() }
        cell.update(with: self.adventuringEpisodes[indexPath.row])
        cell.adventuringTaskButton.tag = indexPath.row
        cell.adventuringTaskButton.addTarget(self, action: #selector(self.segueToEpisode(_:)), for: .touchUpInside)
        return cell
        
      case .areaEpisode:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreAreaCell.identifier, for: indexPath) as? ExploreAreaCell else { return UICollectionViewCell() }
        cell.update(with: self.areaEpisodes[indexPath.row])
        return cell
        
      case .episodeList:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCell.identifier, for: indexPath) as? EpisodeCell else { return UICollectionViewCell() }
        cell.update(with: self.episodeList[indexPath.row])
        return cell
      }
    })
    
    dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, _: String, indexPath: IndexPath) -> UICollectionReusableView? in
      
      if let self = self, let titleSupplementaryView = collectionView.dequeueReusableSupplementaryView(
        ofKind: UICollectionView.elementKindSectionHeader,
        withReuseIdentifier: TitleSupplementaryView.reuseIdentifier,
        for: indexPath) as? TitleSupplementaryView {
        
        titleSupplementaryView.textLabel.text = "\(sectionArray[indexPath.section].rawValue)"
        return titleSupplementaryView
      } else {
        return UICollectionReusableView()
      }
    }
  }
  
  private func configSnapshot() {
    var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    sectionArray.forEach { section in
      currentSnapshot.appendSections([section])
    }
    // Tofix
    guard let profile = profile else { return }
    currentSnapshot.appendItems([.profile(profile)], toSection: .profile)
    
    let area = self.areaEpisodes.map { Item.areaEpisode($0) }
    currentSnapshot.appendItems(area, toSection: .areaEpisode)
    
    let episodeItems = episodeList.map { Item.episode($0) }
    currentSnapshot.appendItems(episodeItems, toSection: .episodeList)
    
    let adventuringEpisode = adventuringEpisodes.map { Item.adventuringEpisode($0) }
    currentSnapshot.appendItems(adventuringEpisode, toSection: .doingEpisode)
    
    dataSource.apply(currentSnapshot, animatingDifferences: true)
  }
}

extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      print("Profile row is clicked, pop to ProfileVC")
      let profileVC = ProfileViewController()
      profileVC.userProfile = profile
      navigationController?.pushViewController(profileVC, animated: true)
    case 1:
      print("DoingEpisode Section Button is clicked, disable the select function")
    case 2:
      print("AreaEpisode is clicked, pop to spesific task")
      let episodeDetailVC = EpisodeDetailViewController()
      episodeDetailVC.episode = episodeList[indexPath.row]
      episodeDetailVC.user = profile
      self.navigationController?.pushViewController(episodeDetailVC, animated: true)
    case 3:
      print("EpisodeList is clicked, pop to spesific task")
      let episodeDetailVC = EpisodeDetailViewController()
      episodeDetailVC.episode = episodeList[indexPath.row]
      episodeDetailVC.user = profile
      self.navigationController?.pushViewController(episodeDetailVC, animated: true)
    default:
      break
    }
  }
}
