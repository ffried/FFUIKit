//
//  UIImage+FixOrientation.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 29/02/16.
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
