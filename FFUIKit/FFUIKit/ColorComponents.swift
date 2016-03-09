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
    public static let blackRGBA = ColorComponents.RGBA(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    public static let blackBWA = ColorComponents.BWA(white: 0.0, alpha: 1.0)
    public static let blackHSBA = ColorComponents.HSBA(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0)
    
    case RGBA(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    case HSBA(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)
    case BWA(white: CGFloat, alpha: CGFloat)
    
    public var color: UIColor { return UIColor(components: self) }
    
    public mutating func updateFromColor(color: UIColor) -> Bool {
        var updated = false
        switch self {
        case .RGBA(var red, var green, var blue, var alpha):
            updated = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self = .RGBA(red: red, green: green, blue: blue, alpha: alpha)
        case .BWA(var white, var alpha):
            updated = color.getWhite(&white, alpha: &alpha)
            self = .BWA(white: white, alpha: alpha)
        case .HSBA(var hue, var saturation, var brightness, var alpha):
            updated = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            self = .HSBA(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        return updated
    }
    
    // Extract brightness. Alpha is ignored. Calculated according to http://www.w3.org/WAI/ER/WD-AERT/#color-contrast for RGBA.
    public var brightness: CGFloat {
        switch self {
        case .RGBA(let red, let green, let blue, _):
            return red * 0.299 + green * 0.587 + blue * 0.114
        case .HSBA(_, let brightness, _, _):
            return brightness
        case .BWA(let white, _):
            return white
        }
    }
    
    // Extracts the alpha value.
    public var alpha: CGFloat {
        switch self {
        case .RGBA(_, _, _, let alpha):
            return alpha
        case .HSBA(_, _, _, let alpha):
            return alpha
        case .BWA(_, let alpha):
            return alpha
        }
    }
    
    public var isDarkColor: Bool {
        return brightness < 0.5
    }
    
    public var isClearColor: Bool {
        return alpha <= 0.0
    }
    
    // Pass 0.1 to increase brightness by 10%
    // Pass -0.1 to decrease brightness by 10%
    public mutating func changeBrightnessByPercent(percent: CGFloat) {
        func applyChange(value: CGFloat) -> CGFloat {
            return max(min(value + percent, 1.0), 0.0)
        }
        switch self {
        case .RGBA(let red, let green, let blue, let alpha):
            self = .RGBA(red: applyChange(red), green: applyChange(green), blue: applyChange(blue), alpha: alpha)
        case .BWA(let white, let alpha):
            self = .BWA(white: applyChange(white), alpha: alpha)
        case .HSBA(let hue, let saturation, let brightness, let alpha):
            self = .HSBA(hue: hue, saturation: saturation, brightness: applyChange(brightness), alpha: alpha)
        }
    }
    
    // Will try in the following order:
    // - RGBA
    // - HSBA
    // - BWA
    public init?(color: UIColor) {
        var rgbaTest = self.dynamicType.blackRGBA
        var hsbaTest = self.dynamicType.blackHSBA
        var bwaTest = self.dynamicType.blackBWA
        if rgbaTest.updateFromColor(color) {
            self = rgbaTest
        } else if hsbaTest.updateFromColor(color) {
            self = hsbaTest
        } else if bwaTest.updateFromColor(color) {
            self = bwaTest
        } else {
            return nil
        }
    }
}
