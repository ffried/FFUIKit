//
//  NotificationAnimationController.swift
//  FFUIKit
//
//  Copyright 2016 Florian Friedrich
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import class Foundation.NSObject
import struct Foundation.TimeInterval
import protocol UIKit.UIViewControllerAnimatedTransitioning
import protocol UIKit.UIViewControllerContextTransitioning
import class UIKit.NSLayoutConstraint
import class UIKit.UIView
import struct UIKit.UITransitionContextViewControllerKey
import struct UIKit.UIViewAnimationOptions
import FFFoundation

internal final class NotificationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var originalVCContainer: UIView!
    
    private final func setupTopBottomConstraints(for view: UIView) {
        if #available(iOS 9.0, *) {
            topConstraint = view.superview?.topAnchor.constraint(equalTo: view.topAnchor)
            bottomConstraint = view.superview?.topAnchor.constraint(equalTo: view.bottomAnchor)
        } else {
            topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview, attribute: .top, multiplier: 1.0, constant: 0.0)
            bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: view.superview, attribute: .top, multiplier: 1.0, constant: 0.0)
        }
    }
    
    @objc(transitionDuration:)
    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    @objc(animateTransition:)
    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        
        let presenting = toVC.isBeingPresented
        guard let vcView = presenting ? fromVC.view : toVC.view,
            let noteView = presenting ? toVC.view : fromVC.view else { return }
        
        let container = transitionContext.containerView
        if presenting {
            originalVCContainer = vcView.superview
            container.addSubview(vcView)
            
            container.addSubview(noteView)
            setupTopBottomConstraints(for: noteView)
            let views: [String: UIView] = ["note": noteView]
            ([bottomConstraint] + ["H:|[note]|"].constraints(with: views)).activate()
            container.layoutIfNeeded()
        }
        
        let options: UIViewAnimationOptions = [.beginFromCurrentState, .allowAnimatedContent, .allowUserInteraction, .curveEaseInOut]
        let duration = transitionDuration(using: transitionContext)
        let animations = {
            if presenting {
                self.bottomConstraint.isActive = false
                self.topConstraint.isActive = true
            } else {
                self.topConstraint.isActive = false
                self.bottomConstraint.isActive = true
            }
            container.layoutIfNeeded()
        }
        let completion = { (finished: Bool) in
            if !presenting {
                self.originalVCContainer.addSubview(vcView)
            }
            transitionContext.completeTransition(finished)
        }
        if transitionContext.isAnimated {
            if presenting {
                //            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: options, animations: animations, completion: completion)
                UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: animations, completion: completion)
            } else {
                UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: animations, completion: completion)
            }
        } else {
            animations()
            completion(true)
        }
    }
}
