//
//  BWA.swift
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

import class UIKit.UIColor


public protocol BWBaseColorComponents: OpaqueColorComponents {
    var white: Value { get set }
}

public protocol BWColorComponents: BWBaseColorComponents {
    init(white: Value)
}

public protocol BWAColorComponents: BWBaseColorComponents, ColorComponents {
    init(white: Value, alpha: Value)
}

extension BWAColorComponents {
    @inlinable
    public init<BW: BWColorComponents>(bw: BW, alpha: Value) where BW.Value == Value {
        self.init(white: bw.white, alpha: alpha)
    }
}

extension BWColorComponents where Value: BinaryInteger {
    public init<Other: BWBaseColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(white: .init(other.white))
    }

    public init<Other: BWBaseColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(white: .init(colorConverting: other.white))
    }

    public init?<Other: BWBaseColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let white = Value(colorConvertingExactly: other.white) else { return nil }
        self.init(white: white)
    }
}

extension BWColorComponents where Value: BinaryFloatingPoint {
    public init<Other: BWBaseColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(white: .init(colorConverting: other.white))
    }

    public init?<Other: BWBaseColorComponents>(exactly other: Other) where Other.Value: BinaryInteger {
        guard let white = Value(colorConvertingExactly: other.white) else { return nil }
        self.init(white: white)
    }

    public init<Other: BWBaseColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(white: .init(other.white))
    }

    public init?<Other: BWBaseColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let white = Value(exactly: other.white) else { return nil }
        self.init(white: white)
    }
}

extension BWAColorComponents where Value: BinaryInteger {
    public init<Other: BWAColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(white: .init(other.white), alpha: .init(other.alpha))
    }

    public init<Other: BWAColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(white: .init(colorConverting: other.white), alpha: .init(colorConverting: other.alpha))
    }

    public init?<Other: BWAColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let white = Value(colorConvertingExactly: other.white),
            let alpha = Value(colorConvertingExactly: other.alpha)
            else { return nil }
        self.init(white: white, alpha: alpha)
    }
}

extension BWAColorComponents where Value: BinaryFloatingPoint {
    public init<Other: BWAColorComponents>(_ other: Other) where Other.Value: BinaryInteger {
        self.init(white: .init(colorConverting: other.white), alpha: .init(colorConverting: other.alpha))
    }

    public init?<Other: BWAColorComponents>(exactly other: Other) where Other.Value: BinaryInteger {
        guard let white = Value(colorConvertingExactly: other.white),
            let alpha = Value(colorConvertingExactly: other.alpha)
            else { return nil }
        self.init(white: white, alpha: alpha)
    }

    public init<Other: BWAColorComponents>(_ other: Other) where Other.Value: BinaryFloatingPoint {
        self.init(white: .init(other.white), alpha: .init(other.alpha))
    }

    public init?<Other: BWAColorComponents>(exactly other: Other) where Other.Value: BinaryFloatingPoint {
        guard let white = Value(exactly: other.white), let alpha = Value(exactly: other.alpha)
            else { return nil }
        self.init(white: white, alpha: alpha)
    }
}

// MARK: - FloatingPointOpaqueColorComponents
extension BWBaseColorComponents where Self: FloatingPointOpaqueColorComponents {
    @inlinable
    public var brightness: Value { return white }

    @inlinable
    public mutating func changeBrightness(by percent: Value) {
        apply(percent: percent, to: &white)
    }
}

// MARK: - UI{Opaque}ColorComponents
fileprivate extension UIColor {
    func _extractBWA() -> (BWA<CGFloat>, isExact: Bool) {
        var bwa = BWA<CGFloat>(white: 0, alpha: 1)
        let isExact = getWhite(&bwa.bw.white, alpha: &bwa.alpha)
        return (bwa, isExact)
    }
}

extension BWColorComponents where Self: UIOpaqueColorCompontents, Value: BinaryFloatingPoint {
    @inlinable
    public var color: UIColor { return UIColor(white: .init(white), alpha: 1) }

    public init?(exactly color: UIColor) {
        let (bwa, isExact) = color._extractBWA()
        guard isExact else { return nil }
        self.init(bwa)
    }

    public init(_ color: UIColor) {
        self.init(color._extractBWA().0)
    }
}

extension BWAColorComponents where Self: UIOpaqueColorCompontents, Value: BinaryFloatingPoint {
    @inlinable
    public var color: UIColor { return UIColor(white: .init(white), alpha: .init(alpha)) }

    public init?(exactly color: UIColor) {
        let (bwa, isExact) = color._extractBWA()
        guard isExact else { return nil }
        self.init(bwa)
    }

    public init(_ color: UIColor) {
        self.init(color._extractBWA().0)
    }
}

// MARK: - BW / BWA
public struct BW<Value: ColorCompontentValue>: BWColorComponents {
    public var white: Value

    @inlinable
    public init(white: Value) {
        self.white = white
    }
}

public struct BWA<Value: ColorCompontentValue>: BWAColorComponents {
    public var bw: BW<Value>
    public var alpha: Value

    @inlinable
    public var white: Value {
        get { return bw.white }
        set { bw.white = newValue }
    }

    @inlinable
    public init(bw: BW<Value>, alpha: Value) {
        (self.bw, self.alpha) = (bw, alpha)
    }

    @inlinable
    public init(white: Value, alpha: Value) {
        self.init(bw: .init(white: white), alpha: alpha)
    }
}

extension BW: FloatingPointOpaqueColorComponents where Value: FloatingPoint {}
extension BWA: FloatingPointOpaqueColorComponents where Value: FloatingPoint {}
extension BW: UIOpaqueColorCompontents where Value: BinaryFloatingPoint {}
extension BWA: UIOpaqueColorCompontents where Value: BinaryFloatingPoint {}

extension BW: Encodable where Value: Encodable {}
extension BWA: Encodable where Value: Encodable {}
extension BW: Decodable where Value: Decodable {}
extension BWA: Decodable where Value: Decodable {}
