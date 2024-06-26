//
//  FireStoreManager.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/11.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Firebase

class FireStoreManager {
  static var shared = FireStoreManager()
  let firestore = Firestore.firestore()
  var episode: Episode?
  
  // MARK: - Function
  // fetch episode ID list
  func fetchCollection(collectionName: String, getList: @escaping ([String]) -> Void) {
    firestore.collection(collectionName).getDocuments { snapshots, error in
      if let error = error { print(error) }
      guard let snapshots = snapshots else {
        print("Get snapshot as nil when fetch collection")
        return
      }
      let list: [String] = snapshots.documents.map { document in
        return document.documentID
      }
      getList(list)
    }
  }
  
  func fetchCollectionQuery(collectionName: String, sendSnapshots: @escaping (QuerySnapshot) -> Void) {
    firestore.collection(collectionName).getDocuments { snapshots, error in
      if let error = error {
        print("FireStoreManager.fetchCollectionQueryDoc Failed to get snapshots: \(error)")
      }
      guard let snapshots = snapshots else {
        print("Get snapshot as nil when fetch collection")
        return
      }
      sendSnapshots(snapshots)
    }
  }
  
  func fetchDocument(collection: String,
                     id: String,
                     getDocument: @escaping (DocumentSnapshot) -> Void) {
    firestore.collection(collection).document(id).getDocument { snapshot, error in
      if let error = error { print(error) }
      
      guard let snapshot = snapshot else {
        print("Get snapshot as nil when fetch document")
        return
      }
      getDocument(snapshot)
    }
  }
  
  func fetchFilteredSnapshots(collection: String,
                              field: String,
                              with: String,
                              sendFilteredquery: @escaping (QuerySnapshot) -> Void) {
    firestore.collection(collection).whereField(field, isEqualTo: with).getDocuments { snapshots, error in
      if let error = error { print(error) }
      
      guard let snapshots = snapshots else {
        print("FirestoreManager.fetchFilteredSnapshots Get snapshot as nil when fetch document")
        return
      }
      sendFilteredquery(snapshots)
    }
  }
  
  func fetchFilteredArrayQuery(collection: String,
                               field: String,
                               with: [Any],
                               sendFilteredquery: @escaping (QuerySnapshot) -> Void) {
    firestore.collection(collection).whereField(field, in: with).getDocuments { snapshots, error in
      if let error = error {
        print("FirestoreManager.fetchFilteredArrayQuery fail to get snapshots from Firebase: \(error)")
      }
      guard let snapshots = snapshots else {
        print("FirestoreManager.fetchFilteredArrayQuery Get snapshot as nil when fetch document")
        return
      }
      sendFilteredquery(snapshots)
    }
  }
  
  func filterDocument(collection: String, field: String, with: String, sendSnapshot: @escaping (DocumentSnapshot) -> Void) {
    firestore.collection(collection).whereField(field, isEqualTo: with).getDocuments { snapshot, error in
      if let error = error {
        print("filterDocument fail to get snapshot: \(error)")
      }
      guard let snapshot = snapshot,
            let document = snapshot.documents.first
      else { return }
      sendSnapshot(document)
    }
  }
  
  func updateUserProfile(userID: String, adventuringEpisode: AdventuringEpisode) {
    do {
      let userProfile = firestore.collection("Profile").document(userID)
      userProfile.getDocument { snapshot, error in
        do {
          guard var data = try snapshot?.data(as: Profile.self)
          else { return }
          data.adventuringEpisode.append(adventuringEpisode)
          try userProfile.setData(from: data, mergeFields: ["adventuringEpisode"])
        } catch {
          print("FireStoreManager fail to get Profile document: \(error)")
        }
      }
    }
  }
  
  func getDocumentReference(collection: String,
                            id: String,
                            sendDocRef: @escaping (DocumentReference) -> Void) {
    let ref = firestore.collection(collection).document(id)
    sendDocRef(ref)
  }
  
  func getFilteredDocumentRef(collection: String,
                              id: String,
                              field: String,
                              sendDocRef: @escaping (DocumentReference) -> Void) {
    
  }
}
