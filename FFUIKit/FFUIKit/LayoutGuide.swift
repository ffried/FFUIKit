//
//  LayoutGuide.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 11.2.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import UIKit

@available(iOS, introduced=7.0)
public class LayoutGuide: NSObject, UILayoutSupport {
    public private(set) var length: CGFloat
    
    public private(set) var originalGuide: UILayoutSupport
    public required init(originalGuide: UILayoutSupport, length: CGFloat = 0.0) {
        self.originalGuide = originalGuide
        self.length = length
        super.init()
    }
    
    convenience init(originalGuide: UILayoutSupport) { self.init(originalGuide: originalGuide, length: 0.0) }
    
    @available(iOS 9.0, *)
    public var topAnchor: NSLayoutYAxisAnchor {
        return originalGuide.topAnchor
    }
    
    @available(iOS 9.0, *)
    public var bottomAnchor: NSLayoutYAxisAnchor {
        return originalGuide.bottomAnchor
    }
    
    @available(iOS 9.0, *)
    public var heightAnchor: NSLayoutDimension {
        return originalGuide.heightAnchor
    }
}
