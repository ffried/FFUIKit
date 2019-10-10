//
//  UIColor+ColorComponents.swift
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

import struct CoreGraphics.CGFloat
import class UIKit.UIColor

extension UIColor {
    @inlinable
    public convenience init(rgba: RGBA<CGFloat>) {
        self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }

    @inlinable
    public convenience init(hsba: HSBA<CGFloat>) {
        self.init(hue: hsba.hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
    }

    @inlinable
    public convenience init(bwa: BWA<CGFloat>) {
        self.init(white: bwa.white, alpha: bwa.alpha)
    }
}
