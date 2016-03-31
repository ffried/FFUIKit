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

internal final class NotificationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var originalVCContainer: UIView!
    
    private final func setupTopBottomConstraints(view: UIView) {
        topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1.0, constant: 0.0)
        bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1.0, constant: 0.0)
    }
    
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
            setupTopBottomConstraints(noteView)
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
}
