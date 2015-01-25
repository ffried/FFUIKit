//
//  UIColor+Hex.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFUIKit

public extension UIColor {
    public convenience init(hex: String) {
        var rawHex = hex
        if hex.hasPrefix("#") {
            rawHex = hex.substringFromIndex(hex.rangeOfString("#")!.endIndex)
        }
        if hex.hasPrefix("0x") {
            rawHex = hex.substringFromIndex(hex.rangeOfString("0x")!.endIndex)
        }
        
        let count = countElements(rawHex)
        assert((count == 6 || count == 8), "Hex string has to have either 6 or 8 characters (without # or 0x)")
        
        var startIndex = rawHex.startIndex
        let redHex = rawHex.substringWithRange(startIndex..<advance(startIndex, 2))
        startIndex = advance(startIndex, 2)
        let greenHex = rawHex.substringWithRange(startIndex..<advance(startIndex, 2))
        startIndex = advance(startIndex, 2)
        let blueHex = rawHex.substringWithRange(startIndex..<advance(startIndex, 2))
        var alphaHex = ""
        if count == 8 {
            startIndex = advance(startIndex, 2)
            alphaHex = rawHex.substringWithRange(startIndex..<advance(startIndex, 2))
        }
        
        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        var a: UInt32 = 255
        NSScanner(string: redHex).scanHexInt(&r)
        NSScanner(string: greenHex).scanHexInt(&g)
        NSScanner(string: blueHex).scanHexInt(&b)
        if countElements(alphaHex) > 0 {
            NSScanner(string: alphaHex).scanHexInt(&a)
        }
        
        self.init(red: (CGFloat(r) / 255.0), green: (CGFloat(g) / 255.0), blue: (CGFloat(b) / 255.0), alpha: (CGFloat(a) / 255.0))
    }
}
