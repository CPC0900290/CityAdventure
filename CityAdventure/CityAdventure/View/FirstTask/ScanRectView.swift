//
//  ScanRectView.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/5.
//

import Foundation
import UIKit

class ScanRectView: UIView {
  var cornerLength: CGFloat = 20.0
  var cornerWidth: CGFloat = 2.0
  var cornerColor: UIColor = .white
  var cornerRadius: CGFloat = 5.0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    backgroundColor = .clear
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let path = UIBezierPath()
    cornerColor.setStroke()
    path.lineWidth = cornerWidth
    
    // Draw top left corner
    path.move(to: CGPoint(x: 0, y: cornerLength))
    path.addLine(to: CGPoint(x: 0, y: cornerRadius))
    path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: true)
    path.addLine(to: CGPoint(x: cornerLength, y: 0))
    
    // Draw top right corner
    path.move(to: CGPoint(x: rect.width - cornerLength, y: 0))
    path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
    path.addArc(withCenter: CGPoint(x: rect.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: 1.5 * .pi, endAngle: 2 * .pi, clockwise: true)
    path.addLine(to: CGPoint(x: rect.width, y: cornerLength))
    
    // Draw bottom right corner
    path.move(to: CGPoint(x: rect.width, y: rect.height - cornerLength))
    path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
    path.addArc(withCenter: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: 0.5 * .pi, clockwise: true)
    path.addLine(to: CGPoint(x: rect.width - cornerLength, y: rect.height))
    
    // Draw bottom left corner
    path.move(to: CGPoint(x: cornerLength, y: rect.height))
    path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
    path.addArc(withCenter: CGPoint(x: cornerRadius, y: rect.height - cornerRadius), radius: cornerRadius, startAngle: 0.5 * .pi, endAngle: .pi, clockwise: true)
    path.addLine(to: CGPoint(x: 0, y: rect.height - cornerLength))
    
    path.stroke()
  }
}
