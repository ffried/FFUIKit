//
//  UIImage+ColorImages.swift
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
    public convenience init?(color: UIColor, size: CGSize) {
        #if swift(>=3.0)
            if #available(iOS 10, *) {
                let renderer = UIGraphicsImageRenderer(size: size)
                let image = renderer.image {
                    $0.cgContext.setFillColor(color.cgColor)
                    $0.cgContext.fill(CGRect(origin: CGPoint.zero, size: size))
                }
                if let cgimage = image.cgImage {
                    self.init(cgImage: cgimage)
                } else {
                    return nil
                }
            } else {
                UIGraphicsBeginImageContext(size)
                defer { UIGraphicsEndImageContext() }
                let context = UIGraphicsGetCurrentContext()
                context?.setFillColor(color.cgColor)
                context?.fill(CGRect(origin: CGPoint.zero, size: size))
                let image = UIGraphicsGetImageFromCurrentImageContext()
                if let cgimage = image?.cgImage {
                    self.init(cgImage: cgimage)
                } else {
                    return nil
                }
            }
        #else
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
        #endif
    }
}
