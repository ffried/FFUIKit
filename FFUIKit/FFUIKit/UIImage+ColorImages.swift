//
//  UIImage+ColorImages.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24/02/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        if let cgimage = image.CGImage {
            self.init(CGImage: cgimage)
        } else {
            return nil
        }
    }
}
