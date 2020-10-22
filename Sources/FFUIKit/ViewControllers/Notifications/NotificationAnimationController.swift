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

#if !os(watchOS)
import Foundation
import UIKit
import FFFoundation

final class NotificationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var originalVCContainer: UIView!

    private final func setupTopBottomConstraints(for view: UIView) {
        topConstraint = view.superview?.topAnchor.constraint(equalTo: view.topAnchor)
        bottomConstraint = view.superview?.topAnchor.constraint(equalTo: view.bottomAnchor)
    }

    @objc(transitionDuration:)
    dynamic internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 0.3 }

    @objc(animateTransition:)
    dynamic internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else { return }

        let presenting = toVC.isBeingPresented
        guard let vcView = presenting ? fromVC.view : toVC.view,
            let noteView = presenting ? toVC.view : fromVC.view,
            let noteVC = (presenting ? toVC : fromVC) as? NotificationControllerProtocol
            else { return }

        let container = transitionContext.containerView
        if presenting {
            originalVCContainer = vcView.superview
            container.addSubview(vcView)
            
            container.addSubview(noteView)
            setupTopBottomConstraints(for: noteView)
            noteVC.noteView.contentViewTopConstraint.isActive = false
            let views: [String: UIView] = ["note": noteView]
            ([bottomConstraint] + ["H:|[note]|"].constraints(with: views)).activate()
            container.layoutIfNeeded()
        }

        let curveOption: UIView.AnimationOptions = presenting ? .curveEaseOut : .curveEaseIn
        let options: UIView.AnimationOptions = [.beginFromCurrentState, .allowAnimatedContent, .allowUserInteraction, curveOption]
        let duration = transitionDuration(using: transitionContext)
        let animations = {
            if presenting {
                self.bottomConstraint.isActive = false
                self.topConstraint.isActive = true
                noteVC.noteView.contentViewTopConstraint.isActive = true
            } else {
                noteVC.noteView.contentViewTopConstraint.isActive = false
                self.topConstraint.isActive = false
                self.bottomConstraint.isActive = true
            }
            container.layoutIfNeeded()
        }
        let completion = { (pos: UIViewAnimatingPosition) in
            if !presenting {
                self.originalVCContainer.addSubview(vcView)
            }
            transitionContext.completeTransition(pos == .end)
        }
        if transitionContext.isAnimated {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration,
                                                           delay: 0,
                                                           options: options,
                                                           animations: animations,
                                                           completion: completion)
        } else {
            animations()
            completion(.end)
        }
    }
}
#endif
