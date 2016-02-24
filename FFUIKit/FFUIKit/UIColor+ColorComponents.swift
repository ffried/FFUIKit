//
//  UIColor+ColorComponents.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24/02/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public extension UIColor {
    
    private func updatedComponents(components: ColorComponents) -> ColorComponents? {
        var comps = components
        return comps.updateFromColor(self) ? comps : nil
    }
    
    public var rgbaComponents: ColorComponents? {
        return updatedComponents(ColorComponents.blackRGBA)
    }
    
    public var hsbaComponents: ColorComponents? {
        return updatedComponents(ColorComponents.blackHSBA)
    }
    
    public var bwaComponents: ColorComponents? {
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
