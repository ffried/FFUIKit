//
//  CGRect+Helpers.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 23.09.17.
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

import CoreGraphics

public extension CGRect {
    @inlinable
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
