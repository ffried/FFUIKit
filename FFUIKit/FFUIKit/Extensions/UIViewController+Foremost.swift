//
//  UIViewController+Foremost.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 09.04.18.
//  Copyright © 2018 Florian Friedrich. All rights reserved.
//

import class UIKit.UIViewController
import class UIKit.UITabBarController
import class UIKit.UINavigationController
import class UIKit.UIPageViewController
import FFFoundation

extension UIViewController {
    @available(iOSApplicationExtension, unavailable)
    @available(watchOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    internal static func findForemostViewController() -> UIViewController? {
        var viewController: UIViewController? = nil
        let rootVC = Application.shared.delegate?.window??.rootViewController
        if let vc = rootVC {
            if let navController = vc as? UINavigationController {
                viewController = navController.topViewController
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
}
