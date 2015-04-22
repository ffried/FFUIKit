//
//  UIImage+Blur.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 22.04.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFUIKit
import CoreImage

public extension UIImage {
    public static var defaultBlurTintColor: UIColor { return UIColor(white: 1, alpha: 0.2) }
    public func blur(radius: Float, tintColor: UIColor? = defaultBlurTintColor) -> UIImage {
        let inputImage = CoreImage.CIImage(CGImage: CGImage)
        
        // Apply Affine-Clamp filter to stretch the image so that it does not
        // look shrunken when gaussian blur is applied
        let transform = CGAffineTransformIdentity
        let clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter.setValue(inputImage, forKey: "inputImage")
        clampFilter.setValue(NSValue(CGAffineTransform: transform), forKey: "inputTransform")
        
        // Apply gaussian blur filter with radius of 30
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
        gaussianBlurFilter.setValue(clampFilter.outputImage, forKey: "inputImage")
        gaussianBlurFilter.setValue(radius, forKey: "inputRadius")
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(gaussianBlurFilter.outputImage, fromRect: inputImage.extent())
        
        // Set up output context.
        UIGraphicsBeginImageContext(size)
        let outputContext = UIGraphicsGetCurrentContext()
        let frame = CGRect(origin: CGPointZero, size: size)
        
        // Invert image coordinates
        CGContextScaleCTM(outputContext, 1.0, -1.0)
        CGContextTranslateCTM(outputContext, 0.0, size.height)
        
        // Draw base image.
        CGContextDrawImage(outputContext, frame, cgImage)
        
        // Apply white tint
        if let tint = tintColor {
            CGContextSaveGState(outputContext)
            CGContextSetFillColorWithColor(outputContext, tint.CGColor)
            CGContextFillRect(outputContext, frame)
            CGContextRestoreGState(outputContext)
        }
        
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
}
