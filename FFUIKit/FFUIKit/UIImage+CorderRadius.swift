//
//  UIImage+CorderRadius.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24/02/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public extension UIImage {
    public final func imageByRoundingCornersTo(cornerRadius: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        drawInRect(rect)
        return UIGraphicsGetImageFromCurrentImageContext()
            .resizableImageWithCapInsets(UIEdgeInsets(
                horizontal: cornerRadius,
                vertical: 0))
    }
}
