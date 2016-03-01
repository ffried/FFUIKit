//
//  UIImage+FixOrientation.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 29/02/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public extension UIImage {
    public final var hasAlpha: Bool {
        let alpha = CGImageGetAlphaInfo(CGImage)
        let allowedValues: [CGImageAlphaInfo] = [.First, .Last, .PremultipliedFirst, .PremultipliedLast]
        return allowedValues.contains(alpha)
    }
    
    public final var normalizedImage: UIImage {
        guard imageOrientation != .Up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        defer { UIGraphicsEndImageContext() }
        drawInRect(CGRect(origin: CGPointZero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
