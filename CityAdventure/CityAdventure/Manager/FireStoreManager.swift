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
  
  func fetchFilteredDoc(collection: String, 
                        field: String,
                        with: String,
                        sendFilteredDoc: @escaping ([String]) -> Void) {
    firestore.collection(collection).whereField(field, isEqualTo: with).getDocuments { snapshots, error in
      if let error = error { print(error) }
      
      guard let snapshots = snapshots else {
        print("Get snapshot as nil when fetch document")
        return
      }
      let list: [String] = snapshots.documents.map { document in
        return document.documentID
      }
      sendFilteredDoc(list)
    }
  }
}
