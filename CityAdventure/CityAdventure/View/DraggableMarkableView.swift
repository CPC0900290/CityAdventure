//
//  MarkableView.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/13.
//

import Foundation
import UIKit

class DraggableMarkerView: UIView {
  
  var onTap: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  lazy var flashLabel: UILabel = {
    let label = UILabel()
    label.text = "限時\n限量"
    label.numberOfLines = 0
    label.font = UIFont(name: "PingFang TC", size: 15)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var flashImage: UIImageView = {
    let imageView = UIImageView()
//    imageView.image = UIImage(named: "Flash-Sale-Icon")
    imageView.backgroundColor = .clear
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private func commonInit() {
    // Add pan gesture recognizer to handle dragging
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    self.addGestureRecognizer(panGesture)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    self.addGestureRecognizer(tapGesture)
    
    // Customize the marker view's appearance
    self.backgroundColor = UIColor(hex: "E7F161", alpha: 1)
    self.layer.cornerRadius = self.frame.width / 2
    
    self.layer.borderColor = UIColor.black.cgColor
    self.layer.borderWidth = 1
    self.layer.shadowRadius = 5
    self.layer.shadowOffset = CGSizeMake(5, 5)
    self.layer.shadowOpacity = 0.7
    
    self.addSubview(flashImage)
    
//    self.addSubview(flashLabel)
    NSLayoutConstraint.activate([
      flashImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      flashImage.topAnchor.constraint(equalTo: self.topAnchor),
      flashImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      flashImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      flashImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      flashImage.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    ])
  }
  
  @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
    onTap?() // Call the closure when the view is tapped
  }
  
  @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    guard let superview = self.superview else { return }
    // Enforce dragging within the superview's bounds, considering safe areas.
    let leftLimit = superview.safeAreaInsets.left + frame.width / 2 + 10
    let rightLimit = superview.bounds.width - superview.safeAreaInsets.right - frame.width / 2 - 10
    let topLimit = superview.safeAreaInsets.top + frame.height / 2 + 10
    let bottomLimit = superview.bounds.height - superview.safeAreaInsets.bottom - frame.height / 2 - 10
    
    switch gesture.state {
    case .changed:
      let translation = gesture.translation(in: superview)
      var newCenter = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
      
      newCenter.x = max(min(newCenter.x, rightLimit), leftLimit)
      newCenter.y = max(min(newCenter.y, bottomLimit), topLimit)
      
      center = newCenter
      gesture.setTranslation(.zero, in: superview)
      
    case .ended:
      let middleX = superview.bounds.width / 2
      let middleY = superview.bounds.height / 2
      let endX: CGFloat = center.x < middleX ? leftLimit : rightLimit
      let endY: CGFloat = center.y < middleY ? topLimit : bottomLimit
      
      // Determine the closest edge: horizontal or vertical
      let distanceToHorizontalEdge = min(
        abs(center.x - superview.safeAreaInsets.left),
        abs(superview.bounds.width - superview.safeAreaInsets.right - center.x)
      )
      let distanceToVerticalEdge = min(
        abs(center.y - superview.safeAreaInsets.top),
        abs(superview.bounds.height - superview.safeAreaInsets.bottom - center.y)
      )
      
      UIView.animate(withDuration: 0.3) {
        if distanceToHorizontalEdge < distanceToVerticalEdge {
          self.center = CGPoint(x: endX, y: self.center.y)
        } else {
          self.center = CGPoint(x: self.center.x, y: endY)
        }
      }
      
    default: break
    }
  }
}
