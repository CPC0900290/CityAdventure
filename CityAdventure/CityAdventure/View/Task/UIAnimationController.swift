//
//  UIAnimationController.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/5/5.
//

import Foundation
import UIKit

class SlideUpAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  let duration = 0.5
  var isPresenting = true
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let key = isPresenting ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
    guard let controller = transitionContext.viewController(forKey: key) else { return }
    
    if isPresenting {
      transitionContext.containerView.addSubview(controller.view)
    }
    
    let presentedFrame = transitionContext.finalFrame(for: controller)
    var dismissedFrame = presentedFrame
    dismissedFrame.origin.y += dismissedFrame.height
    
    let initialFrame = isPresenting ? dismissedFrame : presentedFrame
    let finalFrame = isPresenting ? presentedFrame : dismissedFrame
    
    controller.view.frame = initialFrame
    UIView.animate(withDuration: duration, animations: {
      controller.view.frame = finalFrame
    }) { finished in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
  }
}
