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

import UIKit

public extension UIColor {
    
    private final func updatedComponents(components: ColorComponents) -> ColorComponents? {
        var comps = components
        return comps.updateFromColor(self) ? comps : nil
    }
    
    public final var rgbaComponents: ColorComponents? {
        return updatedComponents(ColorComponents.blackRGBA)
    }
    
    public final var hsbaComponents: ColorComponents? {
        return updatedComponents(ColorComponents.blackHSBA)
    }
    
    public final var bwaComponents: ColorComponents? {
        return updatedComponents(ColorComponents.blackBWA)
    }
    
    public var components: ColorComponents? {
        return ColorComponents(color: self)
    }
    
    public convenience init(components: ColorComponents) {
        switch components {
        case .RGBA(let red, let green, let blue, let alpha):
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        case .HSBA(let hue, let saturation, let brightness, let alpha):
            self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .BWA(let white, let alpha):
            self.init(white: white, alpha: alpha)
        }
    }
}
