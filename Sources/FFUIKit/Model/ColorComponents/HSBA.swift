//
//  HSBA.swift
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

public protocol HSBBaseColorComponents: OpaqueColorComponents {
    var hue: Value { get set }
    var saturation: Value { get set }
    var brightness: Value { get set }
}

public protocol HSBColorComponents: HSBBaseColorComponents {
    init(hue: Value, saturation: Value, brightness: Value)
}

public protocol HSBAColorComponents: HSBBaseColorComponents, ColorComponents {
    init(hue: Value, saturation: Value, brightness: Value, alpha: Value)
}

extension HSBAColorComponents {
    @inlinable
    public init<HSB: HSBColorComponents>(hsb: HSB, alpha: Value) where HSB.Value == Value {
        self.init(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha: alpha)
    }
}

extension HSBColorComponents where Value: BinaryInteger {
    @inlinable
    public init<Other: HSBBaseColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(hue: .init(other.hue), saturation: .init(other.saturation), brightness: .init(other.brightness))
    }
    
    @inlinable
    public init<Other: HSBBaseColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(hue: .init(colorConverting: other.hue),
                  saturation: .init(colorConverting: other.saturation),
                  brightness: .init(colorConverting: other.brightness))
    }
    
    @inlinable
    public init?<Other: HSBBaseColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let hue = Value(colorConvertingExactly: other.hue),
              let saturation = Value(colorConvertingExactly: other.saturation),
              let brightness = Value(colorConvertingExactly: other.brightness)
        else { return nil }
        self.init(hue: hue, saturation: saturation, brightness: brightness)
    }
}

extension HSBColorComponents where Value: BinaryFloatingPoint {
    @inlinable
    public init<Other: HSBBaseColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(hue: .init(colorConverting: other.hue),
                  saturation: .init(colorConverting: other.saturation),
                  brightness: .init(colorConverting: other.brightness))
    }
    
    @inlinable
    public init?<Other: HSBBaseColorComponents>(exactly other: Other) where Other.Value: BinaryInteger {
        guard let hue = Value(colorConvertingExactly: other.hue),
              let saturation = Value(colorConvertingExactly: other.saturation),
              let brightness = Value(colorConvertingExactly: other.brightness)
        else { return nil }
        self.init(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    @inlinable
    public init<Other: HSBBaseColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(hue: .init(other.hue), saturation: .init(other.saturation), brightness: .init(other.brightness))
    }
    
    @inlinable
    public init?<Other: HSBBaseColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let hue = Value(exactly: other.hue),
              let saturation = Value(exactly: other.saturation),
              let brightness = Value(exactly: other.brightness)
        else { return nil }
        self.init(hue: hue, saturation: saturation, brightness: brightness)
    }
}

extension HSBAColorComponents where Value: BinaryInteger {
    @inlinable
    public init<Other: HSBAColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(hue: .init(other.hue), saturation: .init(other.saturation), brightness: .init(other.brightness), alpha: .init(other.alpha))
    }
    
    @inlinable
    public init<Other: HSBAColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(hue: .init(colorConverting: other.hue),
                  saturation: .init(colorConverting: other.saturation),
                  brightness: .init(colorConverting: other.brightness),
                  alpha: .init(colorConverting: other.alpha))
    }
    
    @inlinable
    public init?<Other: HSBAColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let hue = Value(colorConvertingExactly: other.hue),
              let saturation = Value(colorConvertingExactly: other.saturation),
              let brightness = Value(colorConvertingExactly: other.brightness),
              let alpha = Value(colorConvertingExactly: other.alpha)
        else { return nil }
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

extension HSBAColorComponents where Value: BinaryFloatingPoint {
    @inlinable
    public init<Other: HSBAColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(hue: .init(colorConverting: other.hue),
                  saturation: .init(colorConverting: other.saturation),
                  brightness: .init(colorConverting: other.brightness),
                  alpha: .init(colorConverting: other.alpha))
    }
    
    @inlinable
    public init?<Other: HSBAColorComponents>(exactly other: Other) where Other.Value: BinaryInteger {
        guard let hue = Value(colorConvertingExactly: other.hue),
              let saturation = Value(colorConvertingExactly: other.saturation),
              let brightness = Value(colorConvertingExactly: other.brightness),
              let alpha = Value(colorConvertingExactly: other.alpha)
        else { return nil }
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    @inlinable
    public init<Other: HSBAColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(hue: .init(other.hue), saturation: .init(other.saturation), brightness: .init(other.brightness), alpha: .init(other.alpha))
    }
    
    @inlinable
    public init?<Other: HSBAColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let hue = Value(exactly: other.hue),
              let saturation = Value(exactly: other.saturation),
              let brightness = Value(exactly: other.brightness),
              let alpha = Value(exactly: other.alpha)
        else { return nil }
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

// MARK: - FloatingPointOpaqueColorComponents
extension HSBBaseColorComponents where Self: FloatingPointOpaqueColorComponents {
    @inlinable
    public mutating func changeBrightness(by percent: Value) {
        apply(percent: percent, to: &brightness)
    }
}

// MARK: - UI{Opaque}ColorComponents
extension UIColor {
    @usableFromInline
    func _extractHSBA() -> (HSBA<CGFloat>, isExact: Bool) {
        var hsba = HSBA<CGFloat>(hue: 0, saturation: 0, brightness: 0, alpha: 1)
        let isExact = getHue(&hsba.hsb.hue, saturation: &hsba.hsb.saturation, brightness: &hsba.hsb.brightness, alpha: &hsba.alpha)
        return (hsba, isExact)
    }
}

extension HSBColorComponents where Self: UIOpaqueColorCompontents, Value: BinaryFloatingPoint {
    @inlinable
    public var color: UIColor { UIColor(hue: .init(hue), saturation: .init(saturation), brightness: .init(brightness), alpha: 1) }
    
    @inlinable
    public init?(exactly color: UIColor) {
        let (hsba, isExact) = color._extractHSBA()
        guard isExact else { return nil }
        self.init(hsba)
    }
    
    @inlinable
    public init(_ color: UIColor) {
        self.init(color._extractHSBA().0)
    }
}

extension HSBAColorComponents where Self: UIOpaqueColorCompontents, Value: BinaryFloatingPoint {
    @inlinable
    public var color: UIColor { UIColor(hue: .init(hue), saturation: .init(saturation), brightness: .init(brightness), alpha: .init(alpha)) }
    
    @inlinable
    public init?(exactly color: UIColor) {
        let (hsba, isExact) = color._extractHSBA()
        guard isExact else { return nil }
        self.init(hsba)
    }
    
    @inlinable
    public init(_ color: UIColor) {
        self.init(color._extractHSBA().0)
    }
}

// MARK: - RGB{A} -> HSB{A}
extension HSBColorComponents where Value: BinaryFloatingPoint {
    public init<RGB>(rgb: RGB) where RGB: RGBBaseColorComponents, RGB.Value == Value {
        let maxVal = max(rgb.red, rgb.green, rgb.blue)
        let delta = maxVal - min(rgb.red, rgb.green, rgb.blue)
        let hue: Value
        switch maxVal {
        case rgb.red: hue = (rgb.green - rgb.blue) / delta
        case rgb.green: hue = 2 + (rgb.blue - rgb.red) / delta
        case rgb.blue: hue = 4 + (rgb.red - rgb.green) / delta
        default: fatalError("max should always be one of rgb!")
        }
        self.init(hue: hue, saturation: delta.isZero ? 0 : delta / maxVal, brightness: maxVal)
    }
}

extension HSBAColorComponents where Value: BinaryFloatingPoint {
    @inlinable
    public init<RGBA>(rgba: RGBA) where RGBA: RGBBaseColorComponents, RGBA: ColorComponents, RGBA.Value == Value {
        self.init(hsb: HSB(rgb: rgba), alpha: rgba.alpha)
    }
}

// MARK: - HSB / HSBA
public struct HSB<Value: ColorCompontentValue>: HSBColorComponents {
    public var hue: Value
    public var saturation: Value
    public var brightness: Value
    
    public init(hue: Value, saturation: Value, brightness: Value) {
        (self.hue, self.saturation, self.brightness) = (hue, saturation, brightness)
    }
}

public struct HSBA<Value: ColorCompontentValue>: HSBAColorComponents {
    public var hsb: HSB<Value>
    public var alpha: Value
    
    @inlinable
    public var hue: Value {
        get { hsb.hue }
        set { hsb.hue = newValue }
    }
    
    @inlinable
    public var saturation: Value {
        get { hsb.saturation }
        set { hsb.saturation = newValue }
    }
    
    @inlinable
    public var brightness: Value {
        get { hsb.brightness }
        set { hsb.brightness = newValue }
    }
    
    public init(hsb: HSB<Value>, alpha: Value) {
        (self.hsb, self.alpha) = (hsb, alpha)
    }
    
    @inlinable
    public init(hue: Value, saturation: Value, brightness: Value, alpha: Value) {
        self.init(hsb: .init(hue: hue, saturation: saturation, brightness: brightness), alpha: alpha)
    }
}

extension HSB: FloatingPointOpaqueColorComponents where Value: FloatingPoint {}
extension HSBA: FloatingPointOpaqueColorComponents where Value: FloatingPoint {}
extension HSB: UIOpaqueColorCompontents where Value: BinaryFloatingPoint {}
extension HSBA: UIOpaqueColorCompontents where Value: BinaryFloatingPoint {}

extension HSB: Encodable where Value: Encodable {}
extension HSBA: Encodable where Value: Encodable {}
extension HSB: Decodable where Value: Decodable {}
extension HSBA: Decodable where Value: Decodable {}
