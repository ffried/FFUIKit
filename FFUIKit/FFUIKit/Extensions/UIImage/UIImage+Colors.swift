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

fileprivate extension ColorComponents {
    var intensity: CGFloat {
        return brightness * saturation
    }

    var saturation: CGFloat {
        switch self {
        case .rgba(_):
            return color.hsbaComponents?.saturation ?? 0
        case .hsba(_, let saturation, _, _):
            return saturation
        case .bwa(let white, _):
            return white
        }
    }
}

public extension UIImage {
    private func color<I: UnsignedInteger>(from r: I, g: I, b: I, a: I) -> UIColor {
        if a > 0 {
            let alpha = CGFloat(a) / 255.0
            let multiplier = alpha / 255.0
            return UIColor(
                red: CGFloat(r) * multiplier,
                green: CGFloat(g) * multiplier,
                blue: CGFloat(b) * multiplier,
                alpha: alpha
            )
        } else {
            return UIColor(
                red: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: CGFloat(a) / 255.0
            )
        }
    }

    public final var averageColor: UIColor? {
        guard let cgImage = cgImage else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let alphaInfo: CGImageAlphaInfo = .premultipliedLast
        let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .byteOrder32Big]
        guard let context = CGContext(data: nil,
                                      width: 1, height: 1,
                                      bitsPerComponent: 8, bytesPerRow: 4,
                                      space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            else { return nil }
        context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        
        guard let data = context.data else { return nil }
        let rgba = data.assumingMemoryBound(to: UInt8.self)
        
        return color(from: rgba[0], g: rgba[1], b: rgba[2], a: rgba[3])
    }

    public final var colors: [UIColor] {
        guard let cgImage = cgImage else { return [] }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let alphaInfo: CGImageAlphaInfo = .premultipliedLast
        let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .byteOrder32Big]
        guard let context = CGContext(data: nil,
                                      width: cgImage.width, height: cgImage.height,
                                      bitsPerComponent: 8, bytesPerRow: 4,
                                      space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            else { return [] }
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))

        guard let data = context.data else { return [] }
        let rgba = data.assumingMemoryBound(to: UInt8.self)
        return stride(from: 0, to: cgImage.width * cgImage.height * context.bytesPerRow, by: context.bytesPerRow).map {
            color(from: rgba[$0/* + 0*/], g: rgba[$0 + 1], b: rgba[$0 + 2], a: rgba[$0 + 3])
        }
    }

    public final var mostIntenseColor: UIColor? {
        return colors.max { ($0.hsbaComponents?.intensity ?? 0) < ($1.hsbaComponents?.intensity ?? 0) }
    }
    
    public final func imageTinted(with color: UIColor) -> UIImage? {
        func draw(cgImage: CGImage, with rect: CGRect, in context: CGContext) {
            // translate/flip the graphics context (for transforming from CG* coords to UI* coordinates)
            context.translateBy(x: 0.0, y: -1.0)
            context.scaleBy(x: 1.0, y: -1.0)
            
            context.setBlendMode(.colorBurn)
            context.draw(cgImage, in: rect)
            context.clip(to: rect, mask: cgImage)
            context.addRect(rect)
            context.drawPath(using: .fill)
        }
        
        guard let cgImage = cgImage else { return nil }
        let rect = CGRect(origin: .zero, size: size)
        
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
}
