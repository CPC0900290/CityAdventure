//
//  LoginViewController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/30.
//

import Foundation
import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class LoginViewController: UIViewController {
  // MARK: - Properties var
  private var currentNonce: String?
  private let userDefault = UserDefaults()
  private let viewModel = LoginViewModel()
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(backgroundMaterial)
    setupUI()
  }
  
  // MARK: - Setup UI
  private let blurEffect = UIBlurEffect(style: .systemMaterialDark)
  
  private lazy var backgroundMaterial: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: blurEffect)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  lazy var loginTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "Explore the city"
    label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var loginContentLabel: UILabel = {
    let label = UILabel()
    label.text = "穿梭在城市中\n找到你有興趣的角落\n隨時在城市中探險 "
    label.font = UIFont(name: "PingFang TC", size: 18)
    label.textColor = .lightGray
    label.numberOfLines = 0
    label.textAlignment = .left
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var loginWithAppleButton: ASAuthorizationAppleIDButton = {
    let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn,
                                              authorizationButtonStyle: chooseAppleButtonStyle())
    button.cornerRadius = 25
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
    return button
  }()
  
  func chooseAppleButtonStyle() -> ASAuthorizationAppleIDButton.Style {
    return (UITraitCollection.current.userInterfaceStyle == .light) ? .black : .white
  }
  private func setupUI() {
    NSLayoutConstraint.activate([
      backgroundMaterial.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundMaterial.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundMaterial.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      backgroundMaterial.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    [loginTitleLabel, loginContentLabel, loginWithAppleButton].forEach {
      backgroundMaterial.contentView.addSubview($0)
    }
    
    NSLayoutConstraint.activate([
      loginTitleLabel.centerXAnchor.constraint(equalTo: backgroundMaterial.centerXAnchor),
      loginTitleLabel.topAnchor.constraint(equalTo: backgroundMaterial.topAnchor, constant: 40),
      
      loginContentLabel.leadingAnchor.constraint(equalTo: loginTitleLabel.leadingAnchor),
      loginContentLabel.topAnchor.constraint(equalTo: loginTitleLabel.bottomAnchor, constant: 30),
      
      loginWithAppleButton.centerXAnchor.constraint(equalTo: backgroundMaterial.centerXAnchor),
      loginWithAppleButton.widthAnchor.constraint(equalTo: backgroundMaterial.widthAnchor, multiplier: 0.7),
      loginWithAppleButton.heightAnchor.constraint(equalToConstant: 50),
      loginWithAppleButton.bottomAnchor.constraint(equalTo: backgroundMaterial.bottomAnchor, constant: -100)
    ])
  }
  
  // MARK: - Functions
  @objc func signInWithApple() {
    let nonce = randomNonceString()
    currentNonce = nonce
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }
  
  func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
  
  func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      return String(format: "%02x", $0)
    }.joined()
    return hashString
  }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return view.window!
  }
}

extension LoginViewController {
  // MARK: - 透過 Credential 與 Firebase Auth 串接
  func firebaseSignInWithApple(credential: AuthCredential) {
    Auth.auth().signIn(with: credential) { _, error in
      guard error == nil else {
        CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", viewController: self, actionHandler: nil)
        return
      }
      CustomFunc.customAlert(title: "登入成功！", message: "", viewController: self, actionHandler: self.getFirebaseUserInfo)
    }
  }
  
  // MARK: - Firebase 取得登入使用者的資訊
  func getFirebaseUserInfo() {
    let currentUser = Auth.auth().currentUser
    guard let user = currentUser,
          let email = user.email
    else {
      CustomFunc.customAlert(title: "無法取得使用者資料！", message: "", viewController: self, actionHandler: nil)
      return
    }
    let uid = user.uid
    viewModel.postProfile(nickName: "User", userID: uid)
    userDefault.set(uid, forKey: "uid")
    self.dismiss(animated: true)
    CustomFunc.customAlert(title: "使用者資訊", message: "UID：\(uid)\nEmail：\(email)", viewController: self, actionHandler: nil)
  }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    // 登入成功
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        CustomFunc.customAlert(title: "", message: "Unable to fetch identity token", viewController: self, actionHandler: nil)
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        CustomFunc.customAlert(title: "", message: "Unable to serialize token string from data\n\(appleIDToken.debugDescription)", viewController: self, actionHandler: nil)
        return
      }
      // 產生 Apple ID 登入的 Credential
      let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
      // 與 Firebase Auth 進行串接
      firebaseSignInWithApple(credential: credential)
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // 登入失敗，處理 Error
    switch error {
    case ASAuthorizationError.canceled:
      CustomFunc.customAlert(title: "使用者取消登入", message: "", viewController: self, actionHandler: nil)
      
    case ASAuthorizationError.failed:
      CustomFunc.customAlert(title: "授權請求失敗", message: "", viewController: self, actionHandler: nil)
      
    case ASAuthorizationError.invalidResponse:
      CustomFunc.customAlert(title: "授權請求無回應", message: "", viewController: self, actionHandler: nil)
      
    case ASAuthorizationError.notHandled:
      CustomFunc.customAlert(title: "授權請求未處理", message: "", viewController: self, actionHandler: nil)
      
    case ASAuthorizationError.unknown:
      CustomFunc.customAlert(title: "授權失敗，原因不知", message: "", viewController: self, actionHandler: nil)
      
    default:
      break
    }
  }
}
