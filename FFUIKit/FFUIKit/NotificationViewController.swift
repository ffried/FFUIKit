//
//  NotificationViewController.swift
//  NotificationsController
//
//  Created by Florian Friedrich on 13/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public class NotificationViewController: UIViewController {
    
    private lazy var animationController = NotificationAnimationController()
    
    public var notificationView: NotificationViewType! {
        return view as? NotificationViewType
    }
    
//    public override func loadView() {
//        if nibName != nil {
//            super.loadView()
//        }
//        if !isViewLoaded() || !(view is NotificationView) {
//            view = NotificationView()
//        }
//        view.translatesAutoresizingMaskIntoConstraints = false
//    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .greenColor()
    }
    
    // Transitioning & Co.
    public override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { return self }
        set {}
    }

    public override var modalPresentationStyle: UIModalPresentationStyle {
        get { return .Custom }
        set {}
    }
    
}

extension NotificationViewController: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is NotificationViewController {
            return animationController
        }
        return nil
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is NotificationViewController {
            return animationController
        }
        return nil
    }
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        if presented is NotificationViewController {
            return NotificationPresentationController(presentedViewController: presented, presentingViewController:  presenting)
        }
        return nil
    }
}
