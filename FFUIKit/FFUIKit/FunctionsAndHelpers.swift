//
//  FunctionsAndHelpers.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 12.12.14.
//  Copyright 2014 Florian Friedrich
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

#if swift(>=3)
    @available(*, deprecated, message: "Now provided by FFFoundation", renamed: "App")
    public let UIApp = App
#else
    @available(*, deprecated, message="Now provided by FFFoundation", renamed="App")
    public let UIApp = App
#endif

public func findFirstResponder() -> UIResponder? {
    var firstResponder: UIResponder? = nil
    if let window = App.delegate?.window, let view = window {
        #if swift(>=3)
            firstResponder = findFirstResponder(in: view)
        #else
            firstResponder = findFirstResponderInView(view)
        #endif
    }
    return firstResponder
}

#if swift(>=3)
    public func findFirstResponder(in view: UIView) -> UIResponder? {
        var firstResponder: UIResponder? = nil
        if view.isFirstResponder {
            firstResponder = view
        } else {
            for subview in view.subviews where firstResponder == nil {
                if subview.isFirstResponder {
                    firstResponder = subview
                } else {
                    firstResponder = findFirstResponder(in: subview)
                }
            }
        }
        return firstResponder
    }
#else
    public func findFirstResponderInView(view: UIView) -> UIResponder? {
        var firstResponder: UIResponder? = nil
        if view.isFirstResponder() {
            firstResponder = view
        } else {
            for subview in view.subviews {
                if subview.isFirstResponder() {
                    firstResponder = subview
                    break
                } else {
                    firstResponder = findFirstResponderInView(subview)
                    if firstResponder != nil { break }
                }
            }
        }
        return firstResponder
    }
#endif

internal func findForemostViewController() -> UIViewController? {
    var viewController: UIViewController? = nil
    if let vc = App.delegate?.window??.rootViewController {
        if let navController = vc as? UINavigationController {
            viewController = navController.viewControllers.last
        }
        if let tabBarController = vc as? UITabBarController {
            viewController = tabBarController.selectedViewController
        }
        if let pageController = vc as? UIPageViewController {
            viewController = pageController.viewControllers?.first
        }
        if viewController == nil {
            viewController = vc
        }
    }
    if let vc = viewController {
        var presentedViewController = vc
        while let pvc = presentedViewController.presentedViewController {
            presentedViewController = pvc
        }
        viewController = presentedViewController
    }
    return viewController
}
