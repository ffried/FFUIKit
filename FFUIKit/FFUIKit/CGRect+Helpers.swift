//
//  CGRect+Helpers.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 23.09.17.
//  Copyright © 2017 Florian Friedrich. All rights reserved.
//

import CoreGraphics

public extension CGRect {
    @_inlineable
    public var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

public extension CGPoint {
    public init(pointValue: CGFloat) {
        self.init(x: pointValue, y: pointValue)
    }
}

public extension CGSize {
    public init(sideLength: CGFloat) {
        self.init(width: sideLength, height: sideLength)
    }
}
