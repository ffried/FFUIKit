//
//  ColorComponents.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24/02/16.
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

import class UIKit.UIColor

public typealias ColorCompontentValue = Hashable & Comparable & ExpressibleByIntegerLiteral

public protocol OpaqueColorComponents: Hashable {
    associatedtype Value: ColorCompontentValue
}

public protocol ColorComponents: OpaqueColorComponents {
    var alpha: Value { get }
}

public protocol FloatingPointOpaqueColorComponents: OpaqueColorComponents where Value: FloatingPoint {
    var brightness: Value { get }

    // Pass 0.1 to increase brightness by 10%
    // Pass -0.1 to decrease brightness by 10%
    mutating func changeBrightness(by percent: Value)
}

public typealias FloatingPointColorComponents = FloatingPointOpaqueColorComponents & ColorComponents

public protocol UIOpaqueColorCompontents: OpaqueColorComponents {
    var color: UIColor { get }

    init?(exactly color: UIColor)
    init(_ color: UIColor)

    @discardableResult
    mutating func update(from color: UIColor) -> Bool
}

public typealias UIColorCompontents = UIOpaqueColorCompontents & ColorComponents

extension OpaqueColorComponents {
    @inlinable
    public var isClearColor: Bool { return false }
}

extension ColorComponents {
    @inlinable
    public var isClearColor: Bool { return alpha <= 0 }
}

extension FloatingPointOpaqueColorComponents where Value: ExpressibleByFloatLiteral {
    @inlinable
    public var isDarkColor: Bool { return brightness < 0.5 }
}

extension UIOpaqueColorCompontents {
    @discardableResult
    public mutating func update(from color: UIColor) -> Bool {
        guard let newSelf = Self(exactly: color) else { return false }
        self = newSelf
        return true
    }
}

extension FloatingPointOpaqueColorComponents where Value: Numeric {
    @inlinable
    internal func apply(percent: Value, to value: inout Value) {
        value = max(min(value + percent, 1), 0)
    }
}

extension BinaryInteger {
    @inlinable
    internal init<F: BinaryFloatingPoint>(colorConverting other: F) {
        self.init(other * 0xFF)
    }

    @inlinable
    internal init?<F: BinaryFloatingPoint>(colorConvertingExactly other: F) {
        self.init(exactly: other * 0xFF)
    }
}

extension BinaryFloatingPoint {
    @inlinable
    internal init<I: BinaryInteger>(colorConverting other: I) {
        self = Self(other) / 0xFF
    }

    @inlinable
    internal init?<I: BinaryInteger>(colorConvertingExactly other: I) {
        guard let base = Self(exactly: other) else { return nil }
        self = base / 0xFF
    }
}
