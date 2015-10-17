//
//  LayoutGuide.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 11.2.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import UIKit

@available(iOS, introduced=7.0, deprecated=9.0, message="Please use NSLayoutAnchor!")
public class LayoutGuide: NSObject, UILayoutSupport {
    public private(set) var length: CGFloat
    
    public required init(length: CGFloat = 0.0) {
        self.length = length
        super.init()
    }
    
    override convenience init() { self.init(length: 0.0) }
    
    @available(iOS 9.0, *)
    public var topAnchor: NSLayoutYAxisAnchor { fatalError("Please use NSLayoutAnchor!") }
    @available(iOS 9.0, *)
    public var bottomAnchor: NSLayoutYAxisAnchor { fatalError("Please use NSLayoutAnchor!") }
    @available(iOS 9.0, *)
    public var heightAnchor: NSLayoutDimension { fatalError("Please use NSLayoutAnchor!") }
}
