//
//  UIEdgeInsets+Init.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 02/02/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public extension UIEdgeInsets {
    public init(horizontal: CGFloat, vertical: CGFloat) {
       self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
