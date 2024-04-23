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
  private var dataSource: UICollectionViewDiffableDataSource<Section, Episode>!
  private var sectionArray: [Section] = Section.allCases
  private let viewModel = EpisodeViewModel()
  private var episodeIDList: [String] = []
  private var episodeList: [Episode] = []
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchData()
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
}

extension HomeViewController {
  
  private func setupCVLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { sectionNum, _ in
      let sections = self.sectionArray[sectionNum]
      switch sections {
      case .profile: return self.firstLayoutSection()
      case .doingEpisode: return self.firstLayoutSection()
      case .areaEpisode: return self.secondLayoutSection()
      case .episodeList: return self.thirdLayoutSection()
      }
    }
  }
  
  private func firstLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize) // Whithout badge
    item.contentInsets = .init(top: 15, leading: 0, bottom: 15, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension:.fractionalWidth(0.3))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 15)
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    return section
  }
  
  private func secondLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50),heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 0, leading: 0, bottom: 15, trailing: 15)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .estimated(200))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = .init(top: 0, leading: 0, bottom: 15, trailing: 0)
    section.contentInsets.leading = 15
    section.orthogonalScrollingBehavior = .continuous
    section.boundarySupplementaryItems = [
    NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension:.fractionalWidth(1), heightDimension: .estimated(44)), 
                                                elementKind: UICollectionView.elementKindSectionHeader,
                                                alignment:.topLeading)
    ]
    return section
  }
  
  private func thirdLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .absolute(100))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
    group.interItemSpacing = .fixed(CGFloat(10))
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
    section.boundarySupplementaryItems = [
    NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension:.fractionalWidth(1), heightDimension: .estimated(44)),
                                                elementKind: UICollectionView.elementKindSectionHeader,
                                                alignment:.topLeading)
    ]
    return section
  }
  
  private func fourthLayoutSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize) // Whithout badge
    item.contentInsets = .init(top: 15, leading: 0, bottom: 15, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension:.fractionalWidth(0.5))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.contentInsets = .init(top: 0, leading: 15, bottom: 0, trailing: 2)
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    return section
  }
}

// MARK: - UICollecitonViewDiffableDataSource
extension HomeViewController {
  typealias EpisodeDataSource = UICollectionViewDiffableDataSource<Section, Episode>
  private func configDataSource() {
    dataSource = EpisodeDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, _ in
      let section = self.sectionArray[indexPath.section]
      switch section {
      case .profile:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else { return UICollectionViewCell() }
        cell.userNameLabel.text = self.episodeList[0].title
        cell.userTitleLabel.text = "Title"
        return cell
      case .doingEpisode:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdventuringTaskCell.identifier, for: indexPath) as? AdventuringTaskCell else { return UICollectionViewCell() }
        cell.adventuringTaskSloganLabel.text = "TestTestTestTestTest"
        cell.adventuringSloganLabelB.text = "TestTestTestTestTest"
//        cell.adventuringTaskImg.kf.setImage(with: <#T##Source?#>)
        return cell
      case .areaEpisode:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreAreaCell.identifier, for: indexPath) as? ExploreAreaCell else { return UICollectionViewCell() }
        cell.taskTitleLabel.text = "TestTestTestTestTest"
        return cell
      case .episodeList:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCell.identifier, for: indexPath) as? EpisodeCell else { return UICollectionViewCell() }
        cell.episodeTitleLabel.text = "TestTestTestTestTest"
        return cell
      }
    })
    
    dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
      
      if let self = self, let titleSupplementaryView = collectionView.dequeueReusableSupplementaryView(
        ofKind: UICollectionView.elementKindSectionHeader,
        withReuseIdentifier: TitleSupplementaryView.reuseIdentifier,
        for: indexPath) as? TitleSupplementaryView {
//
//        let tutorialCollection = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
        titleSupplementaryView.textLabel.text = "EpisodeList"
        
        return titleSupplementaryView
      } else {
        return UICollectionReusableView()
      }
    }
  }
  
  private func configSnapshot() {
    var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Episode>()
    currentSnapshot.appendSections(sectionArray)
    currentSnapshot.appendItems(episodeList)
    
//    currentSnapshot.appendItems(episodeList, toSection: .episodeList)
//    currentSnapshot.appendItems(episodeList, toSection: .areaEpisode)
//    currentSnapshot.appendItems(episodeList, toSection: .doingEpisode)
//    currentSnapshot.appendItems(episodeList, toSection: .profile)
    dataSource.apply(currentSnapshot, animatingDifferences: true)
  }
}

extension HomeViewController: UICollectionViewDelegate {
  
}
