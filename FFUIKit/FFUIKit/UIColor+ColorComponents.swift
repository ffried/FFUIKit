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

import class UIKit.UIColor

public extension UIColor {
    private final func updated(components: ColorComponents) -> ColorComponents? {
        var comps = components
        return comps.update(from: self) ? comps : nil
    }
    
    public final var rgbaComponents: ColorComponents? {
        return updated(components: ColorComponents.blackRGBA)
    }
    
    public final var hsbaComponents: ColorComponents? {
        return updated(components: ColorComponents.blackHSBA)
    }
    
    public final var bwaComponents: ColorComponents? {
        return updated(components: ColorComponents.blackBWA)
    }
    
    public final var components: ColorComponents? {
        return ColorComponents(color: self)
    }
    
    public convenience init(components: ColorComponents) {
        switch components {
        case .rgba(let red, let green, let blue, let alpha):
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        case .hsba(let hue, let saturation, let brightness, let alpha):
            self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .bwa(let white, let alpha):
            self.init(white: white, alpha: alpha)
        }
    }
}
