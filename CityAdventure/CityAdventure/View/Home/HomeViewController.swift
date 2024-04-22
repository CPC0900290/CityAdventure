//
//  HomeViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/21.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
  // MARK: - Property var
  private var dataSource: UICollectionViewDiffableDataSource<Section, Episode>!
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  // MARK: - UI Setup
  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView()
    collectionView.delegate = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
  
  private func setupUI() {
    collectionView.collectionViewLayout = configureCollectionViewLayout()
    view.addSubview(collectionView)
  }
  
  // MARK: - Function
}

extension HomeViewController {
  private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { (sectionNumber, _) -> NSCollectionLayoutSection? in
      switch sectionNumber {
      case 0: return self.firstLayoutSection()
      case 1: return self.secondLayoutSection()
      case 2: return self.thirdLayoutSection()
      default: return self.fourthLayoutSection()
      }
    }
  }
  
  private func firstLayoutSection() -> NSCollectionLayoutSection {
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
//    section.boundarySupplementaryItems = [
//    NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension:.fractionalWidth(1), heightDimension: .estimated(44)), elementKind: categoryHeaderId, alignment:.topLeading)]
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
//    section.boundarySupplementaryItems = [
//    NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension:.fractionalWidth(1), heightDimension: .estimated(44)), elementKind: categoryHeaderId, alignment:.topLeading)
//    ]
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

extension HomeViewController: UICollectionViewDelegate {
  
}
