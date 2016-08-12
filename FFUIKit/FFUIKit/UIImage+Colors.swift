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
    public final var averageColor: UIColor? {
        guard let cgImage = cgImage else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        #if swift(>=3)
            let alphaInfo: CGImageAlphaInfo = .premultipliedLast
            let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .byteOrder32Big]
        #else
            let alphaInfo: CGImageAlphaInfo = .PremultipliedLast
            let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .ByteOrder32Big]
        #endif
        #if swift(>=3)
            guard let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
                else { return nil }
        #elseif swift(>=2.2) && !swift(>=3)
            let context = CGBitmapContextCreate(nil, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        #else
            let context = CGBitmapContextCreate(UnsafeMutablePointer<UInt8>(), 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        #endif
        #if swift(>=3)
            context.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)), image: cgImage)
        #else
            CGContextDrawImage(context, CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)), cgImage)
        #endif
        
        #if swift(>=3)
            guard let data = context.data else { return nil }
        #else
            let data = context.data
        #endif
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
    public final var mergedColor: UIColor? {
        #if swift(>=3)
            let size = CGSize(width: 1, height: 1)
            if #available(iOS 10, *) {
                let renderer = UIGraphicsImageRenderer(size: size)
                let rgba = renderer.pngData(actions: { (context) in
                    context.cgContext.interpolationQuality = .medium
                    draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
                })
                return UIColor(
                    red: CGFloat(rgba[0]) / 255.0,
                    green: CGFloat(rgba[1]) / 255.0,
                    blue: CGFloat(rgba[2]) / 255.0,
                    alpha: CGFloat(rgba[3]) / 255.0
                )
            } else {
                UIGraphicsBeginImageContext(size)
                defer { UIGraphicsEndImageContext() }
                guard let context = UIGraphicsGetCurrentContext() else { return nil }
                context.interpolationQuality = .medium
                draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
                guard let data = context.data else { return nil }
                let rgba = UnsafePointer<UInt8>(data)
                return UIColor(
                    red: CGFloat(rgba[0]) / 255.0,
                    green: CGFloat(rgba[1]) / 255.0,
                    blue: CGFloat(rgba[2]) / 255.0,
                    alpha: CGFloat(rgba[3]) / 255.0
                )
            }
        #else
            let size = CGSize(width: 1, height: 1)
            UIGraphicsBeginImageContext(size)
            defer { UIGraphicsEndImageContext() }
            let context = UIGraphicsGetCurrentContext()
            CGContextSetInterpolationQuality(context, .medium)
            draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
            let data = context.data
            let rgba = UnsafePointer<UInt8>(data)
            return UIColor(
                red: CGFloat(rgba[0]) / 255.0,
                green: CGFloat(rgba[1]) / 255.0,
                blue: CGFloat(rgba[2]) / 255.0,
                alpha: CGFloat(rgba[3]) / 255.0
            )
        #endif
    }
    
    #if swift(>=3)
    public final func imageTinted(with color: UIColor) -> UIImage? {
        func draw(cgImage: CGImage, with rect: CGRect, in context: CGContext) {
            // translate/flip the graphics context (for transforming from CG* coords to UI* coords)
            context.translateBy(x: 0.0, y: -1.0)
            context.scaleBy(x: 1.0, y: -1.0)
            
            context.setBlendMode(.colorBurn)
            context.draw(in: rect, image: cgImage)
            context.clip(to: rect, mask: cgImage)
            context.addRect(rect)
            context.drawPath(using: .fill)
        }
        
        guard let cgImage = cgImage else { return nil }
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        if #available(iOS 10, *) {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image {
                color.setFill()
                draw(cgImage: cgImage, with: rect, in: $0.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer { UIGraphicsEndImageContext() }
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            
            color.setFill()
            draw(cgImage: cgImage, with: rect, in: context)
            
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    #else
    public final func imageTintedWithColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        // translate/flip the graphics context (for transforming from CG* coords to UI* coords
        context.translateBy(x: 0.0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        context.setBlendMode(.colorBurn)
        context.draw(in: rect, image: cgImage)
        context.clip(to: rect, mask: cgImage)
        context.addRect(rect)
        context.drawPath(using: .fill)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    #endif
}
