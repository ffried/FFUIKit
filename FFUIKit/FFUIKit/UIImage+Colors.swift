//
//  UIImage+Colors.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24/02/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public extension UIImage {
    public var averageColor: UIColor {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var rgba = UnsafePointer<UInt8>()
        let alphaInfo: CGImageAlphaInfo = .PremultipliedLast
        let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .ByteOrder32Big]
        let context = CGBitmapContextCreate(&rgba, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        CGContextDrawImage(context, CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)), CGImage)
        
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
    public var mergedColor: UIColor {
        let size = CGSize(width: 0, height: 0)
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