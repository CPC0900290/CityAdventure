//
//  HomeViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/21.
//

import Foundation
import UIKit
import Kingfisher

class HomeViewController: UIViewController {
  // MARK: - Property var
  private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  private var sectionArray: [Section] = Section.allCases
  private let viewModel = EpisodeViewModel()
  private var episodeIDList: [String] = []
  private var episodeList: [Episode] = []
  private var adventuringEpisodes: [Episode] = []
  private let profile = Profile(nickName: "陳品", titleName: "稱號", avatar: "", playingTaskID: ["2FKfiPWF7OOAs1HsCHTB", "5PIzv445ELf88LS6s7pC"])
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchData()
    fetchUserPlayingData()
//    setupUI()
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
    collectionView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCell")
    collectionView.register(UINib(nibName: "AdventuringTaskCell", bundle: nil), forCellWithReuseIdentifier: "AdventuringTaskCell")
    collectionView.register(UINib(nibName: "ExploreAreaCell", bundle: nil), forCellWithReuseIdentifier: "ExploreAreaCell")
    collectionView.register(UINib(nibName: "EpisodeCell", bundle: nil), forCellWithReuseIdentifier: "EpisodeCell")
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
          dispatchGroup.leave()
        }
      }
      dispatchGroup.notify(queue: .main) {
        self.setupUI()
      }
    }
  }
  
  private func fetchUserPlayingData() {
    guard let episodeIDs = profile.playingTaskID else { return }
    for episdoeID in episodeIDs {
      viewModel.fetchEpisode(id: episdoeID) { episode in
        self.adventuringEpisodes.append(episode)
      }
    }
  }
}

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
  
  private func firstLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize) // Whithout badge
    item.contentInsets = .init(top: 15, leading: 0, bottom: 15, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension:.fractionalWidth(0.8))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    return section
  }
  
  private func secondLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 15, leading: 0, bottom: 15, trailing: 15)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.32),heightDimension: .estimated(200))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
//    section.contentInsets = .init(top: 0, leading: 15, bottom: 15, trailing: 15)
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
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalWidth(0.7))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else { return UICollectionViewCell() }
        cell.userNameLabel.text = self.profile.nickName
        cell.userTitleLabel.text = self.profile.titleName
        return cell
      case .doingEpisode:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdventuringTaskCell.identifier, for: indexPath) as? AdventuringTaskCell else { return UICollectionViewCell() }
//        cell.adventuringTaskSloganLabel.text = "Let's Make Our"
//        cell.adventuringSloganLabelB.text = "Life so a Life"
        cell.update(with: self.adventuringEpisodes[indexPath.row])
        return cell
      case .areaEpisode:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreAreaCell.identifier, for: indexPath) as? ExploreAreaCell else { return UICollectionViewCell() }
        cell.update(with: self.episodeList[indexPath.row])
//        cell.taskTitleLabel.text = self.episodeList[indexPath.row].title
        return cell
      case .episodeList:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCell.identifier, for: indexPath) as? EpisodeCell else { return UICollectionViewCell() }
        cell.update(with: self.episodeList[indexPath.row])
//        cell.episodeTitleLabel.text = self.episodeList[indexPath.row].title
        return cell
      }
    })
    
    dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, _: String, indexPath: IndexPath) -> UICollectionReusableView? in
      
      if let self = self, let titleSupplementaryView = collectionView.dequeueReusableSupplementaryView(
        ofKind: UICollectionView.elementKindSectionHeader,
        withReuseIdentifier: TitleSupplementaryView.reuseIdentifier,
        for: indexPath) as? TitleSupplementaryView {
        
        titleSupplementaryView.textLabel.text = "\(sectionArray[indexPath.section])"
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
    currentSnapshot.appendItems([.profile(profile)], toSection: .profile)
    
    let episodeItems = episodeList.map { Item.episode($0) }
    currentSnapshot.appendItems(episodeItems, toSection: .episodeList)
    
    let areaEpisodes = episodeList.filter { $0.area == "台北" }.map { Item.episode($0) }
    currentSnapshot.appendItems(areaEpisodes, toSection: .areaEpisode)
    
    let adventuringEpisode = adventuringEpisodes.map { Item.episode($0) }
    currentSnapshot.appendItems(adventuringEpisode, toSection: .doingEpisode)
    dataSource.apply(currentSnapshot, animatingDifferences: true)
  }
}

extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      print("Profile row is clicked, pop to ProfileVC")
    case 1:
      print("DoingEpisode is clicked, disable the select function")
    case 2:
      print("AreaEpisode is clicked, pop to spesific task")
      let taskVC = TaskViewController()
      // ToFix: 每個section會吃到的List應該會是不同的
      taskVC.episodeID = episodeIDList[indexPath.row]
      taskVC.episodeForUser = episodeList[indexPath.row]
      self.navigationController?.pushViewController(taskVC, animated: true)
    case 3:
      print("EpisodeList is clicked, pop to spesific task")
      // ToFix: 每個section會吃到的List應該會是不同的
      let taskVC = TaskViewController()
      taskVC.episodeID = episodeIDList[indexPath.row]
      taskVC.episodeForUser = episodeList[indexPath.row]
      self.navigationController?.pushViewController(taskVC, animated: true)
    default:
      break
    }
  }
}