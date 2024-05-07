//
//  ProfileViewModel.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/27.
//

import Foundation
import FirebaseAuth

protocol ProfileModelsUpdateProtocol: AnyObject {
  func updatedDataModels()
  func updateDataModel(_ index: Int)
}

extension ProfileModelsUpdateProtocol {
  func updateDataModel(_ index: Int) {}
}

class ProfileViewModel {
  private var delegate: ProfileModelsUpdateProtocol?
  var finishedList: [Episode] = [] {
    didSet {
      delegate?.updatedDataModels()
    }
  }
  
  func logout() {
    let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
    } catch let signOutError as NSError {
      print("Error signing out: %@", signOutError)
    }
  }
  
  func deleteAccount() async -> Bool {
    let user = Auth.auth().currentUser
    guard let user = user else { return false }
    guard let lastSignInDate = user.metadata.lastSignInDate else { return false }
    let needsReauth = !lastSignInDate.isWithinPast(minutes: 5)

    let needsTokenRevocation = user.providerData.contains { $0.providerID == "apple.com" }

    do {
      if needsReauth || needsTokenRevocation {
        let signInWithApple = SignInWithApple()
        let appleIDCredential = try await signInWithApple()

        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetdch identify token.")
          return false
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
          return false
        }

        let nonce = randomNonceString()
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)

        if needsReauth {
          try await user.reauthenticate(with: credential)
        }
        if needsTokenRevocation {
          guard let authorizationCode = appleIDCredential.authorizationCode else { return false }
          guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return false }

          try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
        }
      }

      try await user.delete()
      return true
    } catch {
      print(error)
      return false
    }
  }
  
  func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while(remainingLength > 0) {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if (errorCode != errSecSuccess) {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }
      
      randoms.forEach { random in
        if (remainingLength == 0) {
          return
        }
        
        if (random < charset.count) {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    return result
  }
  
  func fetchEpisode(id: String, getData sendData: @escaping (Episode) -> Void) {
    DispatchQueue.global(qos: .background).async {
      FireStoreManager.shared.fetchDocument(collection: "EpisodeList", id: id) { documentSnapshot in
        do {
          let result = try documentSnapshot.data(as: Episode.self)
          sendData(result)
        } catch {
          print("ProfileViewModel fail to decode data from Firebase: \(error)")
        }
      }
    }
  }
}
