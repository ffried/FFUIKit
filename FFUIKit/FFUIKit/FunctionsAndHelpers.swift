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

import class UIKit.UIView
import class UIKit.UIResponder
//import class UIKit.UIViewController
//import class UIKit.UITabBarController
//import class UIKit.UINavigationController
//import class UIKit.UIPageViewController
//import FFFoundation

@available(*, deprecated: 2.0, message: "Use UIResponder.firstResponder(in:)", renamed: "UIResponder.firstResponder(in:)")
public func findFirstResponder(in view: UIView) -> UIResponder? {
    return .firstResponder(in: view)
}

// Waiting for https://bugs.swift.org/browse/SR-1226
//@available(iOSApplicationExtension, unavailable)
//@available(watchOSApplicationExtension, unavailable)
//@available(tvOSApplicationExtension, unavailable)
//internal func findForemostViewController() -> UIViewController? {
//    var viewController: UIViewController? = nil
//    let rootVC = Application.shared.delegate?.window??.rootViewController
//    if let vc = rootVC {
//        if let navController = vc as? UINavigationController {
//            viewController = navController.viewControllers.last
//        }
//        if let tabBarController = vc as? UITabBarController {
//            viewController = tabBarController.selectedViewController
//        }
//        if let pageController = vc as? UIPageViewController {
//            viewController = pageController.viewControllers?.first
//        }
//        if viewController == nil {
//            viewController = vc
//        }
//    }
//    if let vc = viewController {
//        var presentedViewController = vc
//        while let pvc = presentedViewController.presentedViewController {
//            presentedViewController = pvc
//        }
//        viewController = presentedViewController
//    }
//    return viewController
//}
