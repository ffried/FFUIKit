//
//  UIViewController+Foremost.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 09.04.18.
//  Copyright © 2018 Florian Friedrich. All rights reserved.
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

import class UIKit.UIViewController
import class UIKit.UITabBarController
import class UIKit.UINavigationController
import class UIKit.UIPageViewController
import FFFoundation

extension UIViewController {
    @available(iOSApplicationExtension, unavailable)
    @available(watchOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    internal static func findForemost() -> UIViewController? {
        var viewController: UIViewController? = nil
        let rootVC = Application.shared.delegate?.window??.rootViewController
        switch rootVC {
        case let navController as UINavigationController:
            viewController = navController.topViewController
        case let tabBarController as UITabBarController:
            viewController = tabBarController.selectedViewController
        case let pageController as UIPageViewController:
            viewController = pageController.viewControllers?.first
        case let vc where viewController == nil:
            viewController = vc
        default: break
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
