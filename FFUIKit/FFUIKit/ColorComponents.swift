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

import UIKit

public enum ColorComponents {
    #if swift(>=3)
    public static let blackRGBA = ColorComponents.rgba(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    public static let blackHSBA = ColorComponents.hsba(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0)
    public static let blackBWA = ColorComponents.bwa(white: 0.0, alpha: 1.0)
    
    case rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    case hsba(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)
    case bwa(white: CGFloat, alpha: CGFloat)
    
    #else
    
    public static let blackRGBA = ColorComponents.RGBA(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    public static let blackHSBA = ColorComponents.HSBA(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0)
    public static let blackBWA = ColorComponents.BWA(white: 0.0, alpha: 1.0)
    
    case RGBA(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    case HSBA(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)
    case BWA(white: CGFloat, alpha: CGFloat)
    #endif
    
    public var color: UIColor { return UIColor(components: self) }
    
    #if swift(>=3)
    public mutating func update(from color: UIColor) -> Bool {
        var updated = false
        switch self {
        case .rgba(var red, var green, var blue, var alpha):
            updated = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self = .rgba(red: red, green: green, blue: blue, alpha: alpha)
        case .hsba(var hue, var saturation, var brightness, var alpha):
            updated = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            self = .hsba(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .bwa(var white, var alpha):
            updated = color.getWhite(&white, alpha: &alpha)
            self = .bwa(white: white, alpha: alpha)
        }
        return updated
    }
    #else
    public mutating func updateFromColor(color: UIColor) -> Bool {
        var updated = false
        switch self {
        case .RGBA(var red, var green, var blue, var alpha):
            updated = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self = .RGBA(red: red, green: green, blue: blue, alpha: alpha)
        case .HSBA(var hue, var saturation, var brightness, var alpha):
            updated = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            self = .HSBA(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .BWA(var white, var alpha):
            updated = color.getWhite(&white, alpha: &alpha)
            self = .BWA(white: white, alpha: alpha)
        }
        return updated
    }
    #endif
    
    // Extract brightness. Alpha is ignored. Calculated according to http://www.w3.org/WAI/ER/WD-AERT/#color-contrast for RGBA.
    public var brightness: CGFloat {
        #if swift(>=3)
        switch self {
        case .rgba(let red, let green, let blue, _):
            return red * 0.299 + green * 0.587 + blue * 0.114
        case .hsba(_, let brightness, _, _):
            return brightness
        case .bwa(let white, _):
            return white
        }
        #else
        switch self {
        case .RGBA(let red, let green, let blue, _):
            return red * 0.299 + green * 0.587 + blue * 0.114
        case .HSBA(_, let brightness, _, _):
            return brightness
        case .BWA(let white, _):
            return white
        }
        #endif
    }
    
    // Extracts the alpha value.
    public var alpha: CGFloat {
        #if swift(>=3)
            switch self {
            case .rgba(_, _, _, let alpha):
                return alpha
            case .hsba(_, _, _, let alpha):
                return alpha
            case .bwa(_, let alpha):
                return alpha
            }
        #else
            switch self {
            case .RGBA(_, _, _, let alpha):
                return alpha
            case .HSBA(_, _, _, let alpha):
                return alpha
            case .BWA(_, let alpha):
                return alpha
            }
        #endif
    }
    
    public var isDarkColor: Bool {
        return brightness < 0.5
    }
    
    public var isClearColor: Bool {
        return alpha <= 0.0
    }
    
    // Pass 0.1 to increase brightness by 10%
    // Pass -0.1 to decrease brightness by 10%
    #if swift(>=3)
    public mutating func changeBrightness(by percent: CGFloat) {
        func applyChange(to value: CGFloat) -> CGFloat {
            return max(min(value + percent, 1.0), 0.0)
        }
        switch self {
        case .rgba(let red, let green, let blue, let alpha):
            self = .rgba(red: applyChange(to: red), green: applyChange(to: green), blue: applyChange(to: blue), alpha: alpha)
        case .hsba(let hue, let saturation, let brightness, let alpha):
            self = .hsba(hue: hue, saturation: saturation, brightness: applyChange(to: brightness), alpha: alpha)
        case .bwa(let white, let alpha):
            self = .bwa(white: applyChange(to: white), alpha: alpha)
        }
    }
    #else
    public mutating func changeBrightnessByPercent(percent: CGFloat) {
        func applyChange(value: CGFloat) -> CGFloat {
            return max(min(value + percent, 1.0), 0.0)
        }
        switch self {
        case .RGBA(let red, let green, let blue, let alpha):
            self = .RGBA(red: applyChange(red), green: applyChange(green), blue: applyChange(blue), alpha: alpha)
        case .HSBA(let hue, let saturation, let brightness, let alpha):
            self = .HSBA(hue: hue, saturation: saturation, brightness: applyChange(brightness), alpha: alpha)
        case .BWA(let white, let alpha):
            self = .BWA(white: applyChange(white), alpha: alpha)
        }
    }
    #endif
    
    // Will try in the following order:
    // - rgba
    // - hsba
    // - bwa
    public init?(color: UIColor) {
        var rgbaTest = self.dynamicType.blackRGBA
        var hsbaTest = self.dynamicType.blackHSBA
        var bwaTest = self.dynamicType.blackBWA
        #if swift(>=3)
            if rgbaTest.update(from: color) {
                self = rgbaTest
            } else if hsbaTest.update(from: color) {
                self = hsbaTest
            } else if bwaTest.update(from: color) {
                self = bwaTest
            } else {
                return nil
            }
        #else
            if rgbaTest.updateFromColor(color) {
                self = rgbaTest
            } else if hsbaTest.updateFromColor(color) {
                self = hsbaTest
            } else if bwaTest.updateFromColor(color) {
                self = bwaTest
            } else {
                return nil
            }
        #endif
    }
}
