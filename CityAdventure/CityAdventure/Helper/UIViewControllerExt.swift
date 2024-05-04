//
//  UIViewControllerExt.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/4.
//

import Foundation
import UIKit

extension UIViewController {
  
  func backToRoot(completion: (() -> Void)? = nil) {
    if presentingViewController != nil {
      let superVC = presentingViewController
      dismiss(animated: false, completion: nil)
      superVC?.backToRoot(completion: completion)
      return
    }
//
//    if let tabbarVC = self as? UITabBarController {
//      tabbarVC.selectedViewController?.backToRoot(completion: completion)
//      return
//    }
//
//    if let navigateVC = self as? UINavigationController {
//      navigateVC.popToRootViewController(animated: false)
//    }
    
    completion?()
  }
}
