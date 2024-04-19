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
  
  private init() {}
  
  func showMarker(in viewController: UIViewController, onTap: @escaping () -> Void) {
    let safeAreaInsets = viewController.view.safeAreaInsets
//    let navigationBarHeight = viewController.navigationController?.navigationBar.frame.height ?? 0
    let tabBarHeight = viewController.tabBarController?.tabBar.frame.height ?? 0
    
    let markerSize: CGFloat = 60
    let initialX = viewController.view.bounds.width - markerSize - 16
    let bottomInset = tabBarHeight > 0 ? tabBarHeight : safeAreaInsets.bottom
    let initialY = viewController.view.bounds.height - bottomInset - markerSize - 50
    
    let initialRect = CGRect(x: initialX, y: initialY, width: markerSize, height: markerSize)
    markerView = DraggableMarkerView(frame: initialRect)
    guard let markerView = markerView else { return }
    markerView.translatesAutoresizingMaskIntoConstraints = false
    markerView.onTap = onTap
    
    viewController.view.addSubview(markerView)
    
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
