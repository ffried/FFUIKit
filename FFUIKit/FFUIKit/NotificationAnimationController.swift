//
//  NotificationAnimationController.swift
//  NotificationsController
//
//  Created by Florian Friedrich on 13/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

internal class NotificationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var originalVCContainer: UIView!
    
    private final func setupTopBottomConstraints(view: UIView) {
        topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1.0, constant: 0.0)
        bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1.0, constant: 0.0)
    }
    
    internal func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    internal func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let container = transitionContext.containerView() else { return }
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else { return }

        let presenting = toVC.isBeingPresented()
        let vcView = presenting ? fromVC.view : toVC.view
        let noteView = presenting ? toVC.view : fromVC.view
        
        if presenting {
            originalVCContainer = vcView.superview
            vcView.setupFullscreenInView(container)
            container.addSubview(noteView)
            setupTopBottomConstraints(noteView)
            let views: [String: UIView] = ["note": noteView, "view": vcView]
            ([bottomConstraint] + ["H:|[view]|", "V:|[view]|", "H:|[note]|"].constraintsWithViews(views)).activate()
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
                vcView.setupFullscreenInView(self.originalVCContainer)
            }
            transitionContext.completeTransition(finished)
        }
        if presenting {
//            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: options, animations: animations, completion: completion)
            UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: animations, completion: completion)
        } else {
            UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: animations, completion: completion)
        }
    }
    
    internal func animationEnded(transitionCompleted: Bool) {
    }
}
