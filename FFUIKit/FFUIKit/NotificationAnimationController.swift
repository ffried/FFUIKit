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

import UIKit
import FFFoundation

internal final class NotificationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var originalVCContainer: UIView!
    
    private final func setupTopBottomConstraints(for view: UIView) {
        #if swift(>=3.0)
            if #available(iOS 9.0, *) {
                topConstraint = view.superview?.topAnchor.constraint(equalTo: view.topAnchor)
                bottomConstraint = view.superview?.topAnchor.constraint(equalTo: view.bottomAnchor)
            } else {
                topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview, attribute: .top, multiplier: 1.0, constant: 0.0)
                bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: view.superview, attribute: .top, multiplier: 1.0, constant: 0.0)
            }
        #else
            if #available(iOS 9.0, *) {
                topConstraint = view.superview?.topAnchor.constraintEqualToAnchor(view.topAnchor)
                bottomConstraint = view.superview?.topAnchor.constraintEqualToAnchor(view.bottomAnchor)
            } else {
                topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1.0, constant: 0.0)
                bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1.0, constant: 0.0)
            }
        #endif
    }
    
    #if swift(>=3.0)
    @objc internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    @objc internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey) else { return }
        
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
    
    #else
    
    @objc internal func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    
    @objc internal func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let container = transitionContext.containerView() else { return }
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else { return }

        let presenting = toVC.isBeingPresented()
        let vcView = presenting ? fromVC.view : toVC.view
        let noteView = presenting ? toVC.view : fromVC.view
        
        if presenting {
            originalVCContainer = vcView.superview
            container.addSubview(vcView)
            
            container.addSubview(noteView)
            setupTopBottomConstraints(for: noteView)
            let views: [String: UIView] = ["note": noteView]
            ([bottomConstraint] + ["H:|[note]|"].constraintsWithViews(views)).activate()
            container.layoutIfNeeded()
        }
        
        let options: UIViewAnimationOptions = [.BeginFromCurrentState, .AllowAnimatedContent, .AllowUserInteraction, .CurveEaseInOut]
        let duration = transitionDuration(transitionContext)
        let animations = {
            if presenting {
                self.bottomConstraint.active = false
                self.topConstraint.active = true
            } else {
                self.topConstraint.active = false
                self.bottomConstraint.active = true
            }
            container.layoutIfNeeded()
        }
        let completion = { (finished: Bool) in
            if !presenting {
                self.originalVCContainer.addSubview(vcView)
            }
            transitionContext.completeTransition(finished)
        }
        if transitionContext.isAnimated() {
            if presenting {
                //            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: options, animations: animations, completion: completion)
                UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: animations, completion: completion)
            } else {
                UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: animations, completion: completion)
            }
        } else {
            animations()
            completion(true)
        }
    }
    #endif
}
