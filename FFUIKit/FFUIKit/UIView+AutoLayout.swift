//
//  UIView+AutoLayout.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 09/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
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
