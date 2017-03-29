//
//  UIColor+Hex.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24.1.15.
//  Copyright 2015 Florian Friedrich
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

import class Foundation.Scanner
import struct CoreGraphics.CGFloat
import class UIKit.UIColor

public extension UIColor {
    public convenience init(hexString hex: String) {
        let rawHex: String
        switch true {
        case hex.hasPrefix("#"):
            rawHex = hex.substring(from: hex.index(hex.startIndex, offsetBy: "#".characters.count))
        case hex.hasPrefix("0x"):
            rawHex = hex.substring(from: hex.index(hex.startIndex, offsetBy: "0x".characters.count))
        default:
            rawHex = hex
        }
        
        let charCount = rawHex.characters.count
        assert((charCount == 6 || charCount == 8), "Hex string has to have either 6 or 8 characters (without # or 0x)")
        
        var startIndex = rawHex.startIndex
        var endIndex = rawHex.index(startIndex, offsetBy: 2)
        let redHex = rawHex.substring(with: startIndex..<endIndex)
        startIndex = endIndex
        endIndex = rawHex.index(startIndex, offsetBy: 2)
        let greenHex = rawHex.substring(with: startIndex..<endIndex)
        startIndex = endIndex
        endIndex = rawHex.index(startIndex, offsetBy: 2)
        let blueHex = rawHex.substring(with: startIndex..<endIndex)
        var alphaHex = ""
        if charCount == 8 {
            startIndex = endIndex
            endIndex = rawHex.index(startIndex, offsetBy: 2)
            alphaHex = rawHex.substring(with: startIndex..<endIndex)
        }
        
        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        var a: UInt32 = 255
        Scanner(string: redHex).scanHexInt32(&r)
        Scanner(string: greenHex).scanHexInt32(&g)
        Scanner(string: blueHex).scanHexInt32(&b)
        if !alphaHex.isEmpty {
            Scanner(string: alphaHex).scanHexInt32(&a)
        }
        
        self.init(red: (CGFloat(r) / 255.0), green: (CGFloat(g) / 255.0), blue: (CGFloat(b) / 255.0), alpha: (CGFloat(a) / 255.0))
    }
}
