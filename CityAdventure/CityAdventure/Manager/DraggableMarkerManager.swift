//
//  DraggableManager.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/13.
//

import Foundation
import UIKit

class DraggableMarkerManager {
  static let shared = DraggableMarkerManager()
  var markerView: DraggableMarkerView?
  private var window: UIWindow?
  
  private init() {}
  
  func showMarker(in viewController: UIViewController, onTap: @escaping () -> Void) {
    // No need to reference the window or rootViewController directly
    let safeAreaInsets = viewController.view.safeAreaInsets
//    let navigationBarHeight = viewController.navigationController?.navigationBar.frame.height ?? 0
    let tabBarHeight = viewController.tabBarController?.tabBar.frame.height ?? 0
    
    // Calculate the position starting from the bottom right, above the tab bar
    let markerSize: CGFloat = 60
    let initialX = viewController.view.bounds.width - markerSize - 16 // 16 points margin
    // Adjust the Y position considering safeAreaInsets.bottom if tabBarHeight is not available
    let bottomInset = tabBarHeight > 0 ? tabBarHeight : safeAreaInsets.bottom
    // Above the tab bar or bottom safe area
    let initialY = viewController.view.bounds.height - bottomInset - markerSize - 50
    
    let initialRect = CGRect(x: initialX, y: initialY, width: markerSize, height: markerSize)
    let markerView = DraggableMarkerView(frame: initialRect)
    markerView.translatesAutoresizingMaskIntoConstraints = false
    // Setup action
    markerView.onTap = onTap
    
    // Add to the viewController's view, not the window
    viewController.view.addSubview(markerView)
    
    // Since we're adding it to the viewController's view, update constraints accordingly
    NSLayoutConstraint.activate([
      markerView.trailingAnchor.constraint(
        equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -16
      ),
      markerView.bottomAnchor.constraint(
        equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -bottomInset - 16
      ),
      markerView.widthAnchor.constraint(equalToConstant: markerSize),
      markerView.heightAnchor.constraint(equalToConstant: markerSize)
    ])
  }
  
  func hideMarker() {
    markerView?.removeFromSuperview()
    markerView = nil
  }
}
