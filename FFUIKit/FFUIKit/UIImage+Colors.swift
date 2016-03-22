//
//  UIImage+Colors.swift
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

public extension UIImage {
    public final var averageColor: UIColor {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let alphaInfo: CGImageAlphaInfo = .PremultipliedLast
        let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .ByteOrder32Big]
        #if swift(>=2.2)
            let context = CGBitmapContextCreate(nil, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        #else
            let context = CGBitmapContextCreate(UnsafeMutablePointer<UInt8>(), 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        #endif
        CGContextDrawImage(context, CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)), CGImage)
        
        let data = CGBitmapContextGetData(context)
        let rgba = UnsafePointer<UInt8>(data)
        
        let color: UIColor
        if rgba[3] > 0 {
            let alpha: CGFloat = CGFloat(rgba[3]) / 255.0
            let multiplier: CGFloat = alpha / 255.0
            color = UIColor(
                red: CGFloat(rgba[0]) * multiplier,
                green: CGFloat(rgba[1]) * multiplier,
                blue: CGFloat(rgba[2]) * multiplier,
                alpha: alpha
            )
        } else {
            color = UIColor(
                red: CGFloat(rgba[0]) / 255.0,
                green: CGFloat(rgba[1]) / 255.0,
                blue: CGFloat(rgba[2]) / 255.0,
                alpha: CGFloat(rgba[3]) / 255.0
            )
        }
        return color
    }
    
    // Draws the image onto a rect of {0, 0, 1, 1} and returns the resulting color mix.
    public final var mergedColor: UIColor {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .Medium)
        drawInRect(CGRect(origin: CGPoint.zero, size: size), blendMode: .Copy, alpha: 1.0)
        let data = CGBitmapContextGetData(context)
        let rgba = UnsafePointer<UInt8>(data)
        return UIColor(
            red: CGFloat(rgba[0]) / 255.0,
            green: CGFloat(rgba[1]) / 255.0,
            blue: CGFloat(rgba[2]) / 255.0,
            alpha: CGFloat(rgba[3]) / 255.0
        )
    }
    
    func imageTintedWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        // translate/flip the graphics context (for transforming from CG* coords to UI* coords
        CGContextTranslateCTM(context, 0.0, size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        CGContextSetBlendMode(context, .ColorBurn)
        CGContextDrawImage(context, rect, CGImage)
        CGContextClipToMask(context, rect, CGImage)
        CGContextAddRect(context, rect)
        CGContextDrawPath(context, .Fill)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
