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
import struct CoreGraphics.CGFloat

public protocol ColorComponents: Hashable, Codable {
    typealias Value = CGFloat //: Hashable & Codable

    var alpha: Value { get }
    var brightness: Value { get }

    // Pass 0.1 to increase brightness by 10%
    // Pass -0.1 to decrease brightness by 10%
    mutating func changeBrightness(by percent: CGFloat)

    var color: UIColor { get }
    init?(color: UIColor)
    mutating func update(from color: UIColor) -> Bool
}

extension ColorComponents {
    @inlinable
    public var isDarkColor: Bool { return brightness < 0.5 }
    @inlinable
    public var isClearColor: Bool { return alpha <= 0 }
}

fileprivate extension ColorComponents {
    func apply(percent: Value, to value: inout Value) {
        value = max(min(value + percent, 1.0), 0.0)
    }
}

// MARK: - RGBA
public struct RGBA: ColorComponents {
    public var red: Value
    public var green: Value
    public var blue: Value
    public var alpha: Value
}

extension RGBA {
    public var brightness: Value { return red * 0.299 + green * 0.587 + blue * 0.114 }

    public mutating func changeBrightness(by percent: CGFloat) {
        // Shouldn't the brightness be applied according to the brightness part above?
        apply(percent: percent, to: &red)
        apply(percent: percent, to: &green)
        apply(percent: percent, to: &blue)
    }

    @inlinable
    public var color: UIColor { return UIColor(red: red, green: green, blue: blue, alpha: alpha) }

    public init?(color: UIColor) {
        var rgba: (red: Value, green: Value, blue: Value, alpha: Value) = (0, 0, 0, 0)
        guard color.getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha) else { return nil }
        self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }

    @inlinable
    public mutating func update(from color: UIColor) -> Bool {
        return color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

extension RGBA {
    public func toHSBA() -> HSBA {
        let maxVal = max(red, green, blue)
        let delta = maxVal - min(red, green, blue)
        let hue: Value
        switch maxVal {
        case red: hue = (green - blue) / delta
        case green: hue = 2 + (blue - red) / delta
        case blue: hue = 4 + (red - green) / delta
        default: fatalError("max should always be one of rgb!")
        }
        return .init(hue: hue, saturation: delta.isZero ? 0 : delta / maxVal, brightness: maxVal, alpha: alpha)
    }
}

// MARK: - HSBA
public struct HSBA: ColorComponents {
    public var hue: Value
    public var saturation: Value
    public var brightness: Value
    public var alpha: Value
}

extension HSBA {
    public mutating func changeBrightness(by percent: CGFloat) {
        apply(percent: percent, to: &brightness)
    }

    @inlinable
    public var color: UIColor { return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha) }

    public init?(color: UIColor) {
        var hsba: (hue: Value, saturation: Value, brightness: Value, alpha: Value) = (0, 0, 0, 0)
        guard color.getHue(&hsba.hue, saturation: &hsba.saturation, brightness: &hsba.brightness, alpha: &hsba.alpha) else { return nil }
        self.init(hue: hsba.hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
    }

    @inlinable
    public mutating func update(from color: UIColor) -> Bool {
        return color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    }
}

// MARK: - BWA
public struct BWA: ColorComponents {
    public var white: Value
    public var alpha: Value
}

extension BWA {
    public mutating func changeBrightness(by percent: CGFloat) {
        apply(percent: percent, to: &white)
    }

    @inlinable
    public var brightness: Value { return white }

    @inlinable
    public var color: UIColor { return UIColor(white: white, alpha: alpha) }

    public init?(color: UIColor) {
        var bwa: (white: Value, alpha: Value) = (0, 0)
        guard color.getWhite(&bwa.white, alpha: &bwa.alpha) else { return nil }
        self.init(white: bwa.white, alpha: bwa.alpha)
    }

    @inlinable
    public mutating func update(from color: UIColor) -> Bool {
        return color.getWhite(&white, alpha: &alpha)
    }
}
