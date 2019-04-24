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
import class UIKit.UIColor

extension UIColor {
    @inlinable
    public convenience init<I: BinaryInteger>(rgbHex: I) {
        self.init(rgba: .init(rgb: .init(RGB(hex: rgbHex)), alpha: 1))
    }

    @inlinable
    public convenience init<I: BinaryInteger>(rgbaHex: I) {
        self.init(rgba: .init(RGBA(hex: rgbaHex)))
    }

    public convenience init(hexString hex: String) {
        let rawHex: String
        switch true {
        case hex.hasPrefix("#"):
            rawHex = String(hex[hex.index(hex.startIndex, offsetBy: "#".count)...])
        case hex.hasPrefix("0x"):
            rawHex = String(hex[hex.index(hex.startIndex, offsetBy: "0x".count)...])
        default:
            rawHex = hex
        }

        let charCount = rawHex.count
        assert(charCount == 6 || charCount == 8,
               "Hex string must have either 6 or 8 characters (without # or 0x)")

        var value: UInt32 = 0
        Scanner(string: rawHex).scanHexInt32(&value)
        if charCount == 8 {
            self.init(rgbaHex: value)
        } else {
            self.init(rgbHex: value)
        }
    }
}
