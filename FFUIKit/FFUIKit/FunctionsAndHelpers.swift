//
//  FunctionsAndHelpers.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 12.12.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

import FFUIKit

public func findFirstResponder() -> UIResponder? {
    var firstResponder: UIResponder? = nil
    if let v = UIApplication.sharedApplication().delegate?.window? {
        firstResponder = findFirstResponderInView(v)
    }
    return firstResponder
}

public func findFirstResponderInView(view: UIView) -> UIResponder? {
    var firstResponder: UIResponder? = nil
    if let subviews = view.subviews as? [UIView] {
        for subview in subviews {
            if subview.isFirstResponder() {
                firstResponder = subview
                break
            } else {
                firstResponder = findFirstResponderInView(subview)
                if firstResponder != nil {
                    break
                }
            }
        }
    }
    return firstResponder
}

internal func findForemostViewController() -> UIViewController? {
    var viewController: UIViewController? = nil
    if let vc = UIApplication.sharedApplication().delegate?.window??.rootViewController {
        if let navController = vc as? UINavigationController {
            viewController = navController.viewControllers.last as? UIViewController
        }
        if let tabBarController = vc as? UITabBarController {
            viewController = tabBarController.selectedViewController
        }
        if let pageController = vc as? UIPageViewController {
            viewController = pageController.viewControllers.first as? UIViewController
        }
        if viewController == nil {
            viewController = vc
        }
    }
    if let vc = viewController {
        var presentedViewController = vc
        while (presentedViewController.presentedViewController != nil) {
            presentedViewController = presentedViewController.presentedViewController!
        }
        viewController = presentedViewController
    }
    return viewController
}
