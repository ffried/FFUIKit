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

import UIKit

public extension UIColor {
    public convenience init(hexString hex: String) {
        var rawHex = hex
        if hex.hasPrefix("#") {
            #if swift(>=3)
                rawHex = hex.substring(from: hex.index(hex.startIndex, offsetBy: "#".characters.count))
            #else
                rawHex = hex.substringFromIndex(hex.startIndex.advancedBy("#".characters.count))
            #endif
        }
        if hex.hasPrefix("0x") {
            #if swift(>=3)
                rawHex = hex.substring(from: hex.index(hex.startIndex, offsetBy: "0x".characters.count))
            #else
                rawHex = hex.substringFromIndex(hex.startIndex.advancedBy("0x".characters.count))
            #endif
        }
        
        let c = rawHex.characters.count
        assert((c == 6 || c == 8), "Hex string has to have either 6 or 8 characters (without # or 0x)")
        
        var startIndex = rawHex.startIndex
        #if swift(>=3)
            var endIndex = rawHex.index(startIndex, offsetBy: 2)
        #endif
        #if swift(>=3)
            let redHex = rawHex.substring(with: startIndex..<endIndex)
            startIndex = endIndex
            endIndex = rawHex.index(startIndex, offsetBy: 2)
            let greenHex = rawHex.substring(with: startIndex..<endIndex)
            startIndex = endIndex
            endIndex = rawHex.index(startIndex, offsetBy: 2)
            let blueHex = rawHex.substring(with: startIndex..<endIndex)
            var alphaHex = ""
            if c == 8 {
                startIndex = endIndex
                endIndex = rawHex.index(startIndex, offsetBy: 2)
                alphaHex = rawHex.substring(with: startIndex..<endIndex)
            }
        #else
            let redHex = rawHex.substringWithRange(startIndex..<startIndex.advancedBy(2))
            startIndex = startIndex.advancedBy(2)
            let greenHex = rawHex.substringWithRange(startIndex..<startIndex.advancedBy(2))
            startIndex = startIndex.advancedBy(2)
            let blueHex = rawHex.substringWithRange(startIndex..<startIndex.advancedBy(2))
            var alphaHex = ""
            if c == 8 {
                startIndex = startIndex.advancedBy(2)
                alphaHex = rawHex.substringWithRange(startIndex..<startIndex.advancedBy(2))
            }
        #endif
        
        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        var a: UInt32 = 255
        #if swift(>=3)
            Scanner(string: redHex).scanHexInt32(&r)
            Scanner(string: greenHex).scanHexInt32(&g)
            Scanner(string: blueHex).scanHexInt32(&b)
            if alphaHex.characters.count > 0 {
                Scanner(string: alphaHex).scanHexInt32(&a)
            }
        #else
            NSScanner(string: redHex).scanHexInt(&r)
            NSScanner(string: greenHex).scanHexInt(&g)
            NSScanner(string: blueHex).scanHexInt(&b)
            if alphaHex.characters.count > 0 {
                NSScanner(string: alphaHex).scanHexInt(&a)
            }
        #endif
            
        
        self.init(red: (CGFloat(r) / 255.0), green: (CGFloat(g) / 255.0), blue: (CGFloat(b) / 255.0), alpha: (CGFloat(a) / 255.0))
    }
}
