//
//  UIView+AutoLayout.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 09/03/16.
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
import FFFoundation

extension UIView {
    public final func enableAutoLayout() {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /**
     Would you really want to use this!?
     */
    public final func disableAutoLayout() {
        if !translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    public final func setupFullscreenInView(view: UIView, withInsets insets: UIEdgeInsets = UIEdgeInsets(), constraintPreparations: (NSLayoutConstraint -> Void)? = nil) -> [NSLayoutConstraint] {
        enableAutoLayout()
        if superview != view {
            if superview != nil {
                removeFromSuperview()
            }
            view.addSubview(self)
        }
        let formats = [
            "H:|-(==left)-[view]-(==right)-|",
            "V:|-(==top)-[view]-(==bottom)-|"
        ]
        let constraints = formats.constraintsWithViews(["view": self], metrics: insets.asMetrics)
        if let preps = constraintPreparations { constraints.forEach(preps) }
        constraints.activate()
        return constraints
    }
}
