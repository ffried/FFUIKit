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

#if !os(watchOS)
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
    
    @discardableResult
    public final func setupFullscreen(in view: UIView, with insets: UIEdgeInsets = .init(), prepare constraintPreparations: ((NSLayoutConstraint) -> Void)? = nil) -> [NSLayoutConstraint] {
        enableAutoLayout()
        if superview != view {
            view.addSubview(self)
        }
        let constraints = [
            "H:|-(==left)-[view]-(==right)-|",
            "V:|-(==top)-[view]-(==bottom)-|"
        ].constraints(with: ["view": self], metrics: insets.asMetrics)
        if let preps = constraintPreparations { constraints.forEach(preps) }
        constraints.activate()
        return constraints
    }
}
#endif
