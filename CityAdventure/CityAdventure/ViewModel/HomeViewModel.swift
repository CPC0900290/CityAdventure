//
//  HomeViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/23.
//

import Foundation
import Firebase
import FirebaseAuth
import RxSwift
import RxCocoa

class HomeViewModel {
  private let userDefault = UserDefaults.standard
  private let disposeBag = DisposeBag()

  // MARK: - State
  let totalEpisodes = BehaviorRelay<[Episode]>(value: [])
  let areaEpisodes = BehaviorRelay<[Episode]>(value: [])
  let adventuringEpisodes = BehaviorRelay<[Episode]>(value: [])
  let profile = BehaviorRelay<Profile?>(value: nil)
  // Fetch all Episode from Firebase
  func fetchTotalEpisodes() -> Single<[Episode]> {
    return Single.create { single in
      FireStoreManager.shared.fetchCollectionQuery(collectionName: "EpisodeList") { [weak self] query in
        do {
          let results = try query.documents.map { snapshot in
            try snapshot.data(as: Episode.self)
          }
          self?.totalEpisodes.accept(results)
          single(.success(results))
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
  
  // Fetch Area Episode from Firebase
  func fetchAreaEpisode(areaName: String) -> Single<[Episode]> {
    return Single.create { single in
      FireStoreManager.shared.fetchFilteredSnapshots(collection: "EpisodeList",
                                                     field: "area",
                                                     with: areaName) { [weak self] query in
        do {
          let results = try query.documents.map { snapshot in
            try snapshot.data(as: Episode.self)
          }
          self?.areaEpisodes.accept(results)
          single(.success(results))
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
  
  // Fetch Adventuring Episode from Firebase
  func fetchAdventuringEpisodes() -> Single<[Episode]> {
    guard let profile = profile.value else { return .just([]) }
    let episodeIDList = profile.adventuringEpisode.map { $0.episodeID }
    guard !episodeIDList.isEmpty else { return .just([]) }

    return Single.create { single in
      FireStoreManager.shared.fetchFilteredArrayQuery(collection: "EpisodeList",
                                                      field: "id",
                                                      with: episodeIDList) { [weak self] query in
        do {
          let results = try query.documents.map { snapshot in
            try snapshot.data(as: Episode.self)
          }
          self?.adventuringEpisodes.accept(results)
          single(.success(results))
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
  
  // Fetch Profile from Firebase
  func fetchProfile() -> Single<Profile> {
    guard let userID = userDefault.value(forKey: UserDefaultsKeys.uid) as? String else {
      return .error(NSError(domain: "HomeViewModel", code: -1, userInfo: nil))
    }

    return Single.create { single in
      FireStoreManager.shared.filterDocument(collection: "Profile", field: "userID", with: userID) { [weak self] document in
        do {
          let data = try document.data(as: Profile.self)
          self?.profile.accept(data)
          single(.success(data))
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
}
