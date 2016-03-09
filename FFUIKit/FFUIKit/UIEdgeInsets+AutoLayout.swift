//
//  UIEdgeInsets+AutoLayout.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 09/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit
import FFFoundation

extension UIEdgeInsets {
    public var asMetrics: NSLayoutConstraint.MetricsDictionary {
        return ["top": top, "left": left, "bottom": bottom, "right": right]
    }
}
