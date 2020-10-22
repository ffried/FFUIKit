//
//  RGBA.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24.04.19.
//  Copyright © 2019 Florian Friedrich. All rights reserved.
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

import struct CoreGraphics.CGFloat
import class UIKit.UIColor

public protocol RGBBaseColorComponents: OpaqueColorComponents {
    var red: Value { get set }
    var green: Value { get set }
    var blue: Value { get set }
}

public protocol RGBColorComponents: RGBBaseColorComponents {
    init(red: Value, green: Value, blue: Value)
}

public protocol RGBAColorComponents: RGBBaseColorComponents, ColorComponents {
    init(red: Value, green: Value, blue: Value, alpha: Value)
}

extension RGBAColorComponents {
    @inlinable
    public init<RGB: RGBColorComponents>(rgb: RGB, alpha: Value) where RGB.Value == Value {
        self.init(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: alpha)
    }
}

extension RGBColorComponents where Value: BinaryInteger {
    @inlinable
    public init<Other: RGBBaseColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(red: .init(other.red), green: .init(other.green), blue: .init(other.blue))
    }
    
    @inlinable
    public init<Other: RGBBaseColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(red: .init(colorConverting: other.red),
                  green: .init(colorConverting: other.green),
                  blue: .init(colorConverting: other.blue))
    }
    
    @inlinable
    public init?<Other: RGBBaseColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let red = Value(colorConvertingExactly: other.red),
              let green = Value(colorConvertingExactly: other.green),
              let blue = Value(colorConvertingExactly: other.blue)
        else { return nil }
        self.init(red: red, green: green, blue: blue)
    }
}

extension RGBColorComponents where Value: BinaryFloatingPoint {
    @inlinable
    public init<Other: RGBBaseColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(red: .init(colorConverting: other.red),
                  green: .init(colorConverting: other.green),
                  blue: .init(colorConverting: other.blue))
    }
    
    @inlinable
    public init?<Other: RGBBaseColorComponents>(exactly other: Other) where Other.Value: BinaryInteger {
        guard let red = Value(colorConvertingExactly: other.red),
              let green = Value(colorConvertingExactly: other.green),
              let blue = Value(colorConvertingExactly: other.blue)
        else { return nil }
        self.init(red: red, green: green, blue: blue)
    }
    
    @inlinable
    public init<Other: RGBBaseColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(red: .init(other.red), green: .init(other.green), blue: .init(other.blue))
    }
    
    @inlinable
    public init?<Other: RGBBaseColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let red = Value(exactly: other.red),
              let green = Value(exactly: other.green),
              let blue = Value(exactly: other.blue)
        else { return nil }
        self.init(red: red, green: green, blue: blue)
    }
}

extension RGBAColorComponents where Value: BinaryInteger {
    @inlinable
    public init<Other: RGBAColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(red: .init(other.red), green: .init(other.green), blue: .init(other.blue), alpha: .init(other.alpha))
    }
    
    @inlinable
    public init<Other: RGBAColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(red: .init(colorConverting: other.red),
                  green: .init(colorConverting: other.green),
                  blue: .init(colorConverting: other.blue),
                  alpha: .init(colorConverting: other.alpha))
    }
    
    @inlinable
    public init?<Other: RGBAColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let red = Value(colorConvertingExactly: other.red),
              let green = Value(colorConvertingExactly: other.green),
              let blue = Value(colorConvertingExactly: other.blue),
              let alpha = Value(colorConvertingExactly: other.alpha)
        else { return nil }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension RGBAColorComponents where Value: BinaryFloatingPoint {
    @inlinable
    public init<Other: RGBAColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(red: .init(colorConverting: other.red),
                  green: .init(colorConverting: other.green),
                  blue: .init(colorConverting: other.blue),
                  alpha: .init(colorConverting: other.alpha))
    }
    
    @inlinable
    public init?<Other: RGBAColorComponents>(exactly other: Other) where Other.Value: BinaryInteger {
        guard let red = Value(colorConvertingExactly: other.red),
              let green = Value(colorConvertingExactly: other.green),
              let blue = Value(colorConvertingExactly: other.blue),
              let alpha = Value(colorConvertingExactly: other.alpha)
        else { return nil }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    @inlinable
    public init<Other: RGBAColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(red: .init(other.red), green: .init(other.green), blue: .init(other.blue), alpha: .init(other.alpha))
    }
    
    @inlinable
    public init?<Other: RGBAColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let red = Value(exactly: other.red),
              let green = Value(exactly: other.green),
              let blue = Value(exactly: other.blue),
              let alpha = Value(exactly: other.alpha)
        else { return nil }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - Hex values
extension RGBColorComponents where Value: BinaryInteger {
    public init(hex: Value) {
        self.init(red:   (hex & 0x00FF0000) >> 16,
                  green: (hex & 0x0000FF00) >> 8,
                  blue:  (hex & 0x000000FF))
    }
}

extension RGBAColorComponents where Value: BinaryInteger {
    public init(hex: Value) {
        self.init(red:   (hex & 0xFF000000) >> 24,
                  green: (hex & 0x00FF0000) >> 16,
                  blue:  (hex & 0x0000FF00) >> 8,
                  alpha: (hex & 0x000000FF))
    }
}

// MARK: Strings
extension BinaryInteger {
    @usableFromInline
    func hexString(uppercase: Bool) -> String {
        let str = String(self, radix: 16, uppercase: uppercase)
        return str.count == 2 ? str : "0" + str
    }
}

extension RGBBaseColorComponents where Value: BinaryInteger {
    @inlinable
    func _rgbHexString(uppercase: Bool) -> String {
        red.hexString(uppercase: uppercase) + green.hexString(uppercase: uppercase) + blue.hexString(uppercase: uppercase)
    }
}

extension RGBBaseColorComponents where Self: ColorComponents, Value: BinaryInteger {
    @inlinable
    func _rgbaHexString(uppercase: Bool) -> String {
        _rgbHexString(uppercase: uppercase) + alpha.hexString(uppercase: uppercase)
    }
}

extension RGBColorComponents where Value: BinaryInteger {
    @inlinable
    public func hexString(prefix: String = "", postfix: String = "", uppercase: Bool = false) -> String {
        prefix + _rgbHexString(uppercase: uppercase) + postfix
    }
}

extension RGBAColorComponents where Value: BinaryInteger {
    @inlinable
    public func hexString(prefix: String = "", postfix: String = "", uppercase: Bool = false) -> String {
        prefix + _rgbaHexString(uppercase: uppercase) + postfix
    }
}

// MARK: - FloatingPointOpaqueColorComponents
extension RGBBaseColorComponents where Self: FloatingPointOpaqueColorComponents, Value: ExpressibleByFloatLiteral {
    public var brightness: Value { red * 0.299 + green * 0.587 + blue * 0.114 }
    
    public mutating func changeBrightness(by percent: Value) {
        // Shouldn't the brightness be applied according to the brightness part above?
        apply(percent: percent, to: &red)
        apply(percent: percent, to: &green)
        apply(percent: percent, to: &blue)
    }
}

// MARK: - UI{Opaque}ColorComponents
extension UIColor {
    @usableFromInline
    func _extractRGBA() -> (RGBA<CGFloat>, isExact: Bool) {
        var rgba = RGBA<CGFloat>(red: 0, green: 0, blue: 0, alpha: 1)
        let isExact = getRed(&rgba.rgb.red, green: &rgba.rgb.green, blue: &rgba.rgb.blue, alpha: &rgba.alpha)
        return (rgba, isExact)
    }
}

extension RGBColorComponents where Self: UIOpaqueColorCompontents, Value: BinaryFloatingPoint {
    @inlinable
    public var color: UIColor { UIColor(red: .init(red), green: .init(green), blue: .init(blue), alpha: 1) }
    
    @inlinable
    public init?(exactly color: UIColor) {
        let (rgba, isExact) = color._extractRGBA()
        guard isExact else { return nil }
        self.init(rgba)
    }
    
    @inlinable
    public init(_ color: UIColor) {
        self.init(color._extractRGBA().0)
    }
}

extension RGBAColorComponents where Self: UIOpaqueColorCompontents, Value: BinaryFloatingPoint {
    @inlinable
    public var color: UIColor { UIColor(red: .init(red), green: .init(green), blue: .init(blue), alpha: .init(alpha)) }
    
    @inlinable
    public init?(exactly color: UIColor) {
        let (rgba, isExact) = color._extractRGBA()
        guard isExact else { return nil }
        self.init(rgba)
    }
    
    @inlinable
    public init(_ color: UIColor) {
        self.init(color._extractRGBA().0)
    }
}

// MARK: - RGB / RGBA
public struct RGB<Value: ColorCompontentValue>: RGBColorComponents {
    public var red: Value
    public var green: Value
    public var blue: Value
    
    public init(red: Value, green: Value, blue: Value) {
        (self.red, self.green, self.blue) = (red, green, blue)
    }
}

public struct RGBA<Value: ColorCompontentValue>: RGBAColorComponents {
    public var rgb: RGB<Value>
    public var alpha: Value
    
    @inlinable
    public var red: Value {
        get { rgb.red }
        set { rgb.red = newValue }
    }
    
    @inlinable
    public var green: Value {
        get { rgb.green }
        set { rgb.green = newValue }
    }
    
    @inlinable
    public var blue: Value {
        get { rgb.blue }
        set { rgb.blue = newValue }
    }
    
    public init(rgb: RGB<Value>, alpha: Value) {
        (self.rgb, self.alpha) = (rgb, alpha)
    }
    
    @inlinable
    public init(red: Value, green: Value, blue: Value, alpha: Value) {
        self.init(rgb: .init(red: red, green: green, blue: blue), alpha: alpha)
    }
}

extension RGB: FloatingPointOpaqueColorComponents where Value: FloatingPoint, Value: ExpressibleByFloatLiteral {}
extension RGBA: FloatingPointOpaqueColorComponents where Value: FloatingPoint, Value: ExpressibleByFloatLiteral {}
extension RGB: UIOpaqueColorCompontents where Value: BinaryFloatingPoint {}
extension RGBA: UIOpaqueColorCompontents where Value: BinaryFloatingPoint {}

extension RGB: Encodable where Value: Encodable {}
extension RGBA: Encodable where Value: Encodable {}
extension RGB: Decodable where Value: Decodable {}
extension RGBA: Decodable where Value: Decodable {}
