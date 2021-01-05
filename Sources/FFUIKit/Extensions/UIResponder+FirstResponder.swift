//
//  UIResponder+FirstResponder.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 19.08.17.
//  Copyright © 2017 Florian Friedrich. All rights reserved.
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
import class UIKit.UIApplication
import class UIKit.UIResponder
import class UIKit.UIView
import FFFoundation

extension UIResponder {
    @available(iOSApplicationExtension, unavailable)
    @available(watchOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public static func findFirstResponder() -> UIResponder? {
        UIApplication.shared.delegate?.window?.flatMap(firstResponder)
    }

    public static func firstResponder(in view: UIView) -> UIResponder? {
        guard !view.isFirstResponder else { return view }
        var firstResponder: UIResponder? = nil
        for subview in view.subviews where firstResponder == nil {
            firstResponder = subview.isFirstResponder ? subview : self.firstResponder(in: subview)
        }
        return firstResponder
    }
}
#endif
