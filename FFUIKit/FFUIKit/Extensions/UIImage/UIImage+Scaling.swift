//
//  UIImage+Scaling.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 21.03.19.
//  Copyright © 2019 Florian Friedrich. All rights reserved.
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

import struct CoreGraphics.CGRect
import struct CoreGraphics.CGSize
import class UIKit.UIImage
import class UIKit.UIGraphicsImageRenderer
import class UIKit.UIGraphicsImageRendererFormat

// Pre iOS 10
import func UIKit.UIGraphicsBeginImageContextWithOptions
import func UIKit.UIGraphicsEndImageContext
import func UIKit.UIGraphicsGetImageFromCurrentImageContext

extension UIImage {
    public func scaled(to size: CGSize) -> UIImage {
        if #available(iOS 10, *) {
            let format = UIGraphicsImageRendererFormat.default()
            format.opaque = !hasAlpha
            format.scale = scale
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            return renderer.image { _ in draw(in: CGRect(origin: .zero, size: size)) }
        } else {
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            defer { UIGraphicsEndImageContext() }
            draw(in: CGRect(origin: .zero, size: size))
            return UIGraphicsGetImageFromCurrentImageContext() ?? self
        }
    }
}
