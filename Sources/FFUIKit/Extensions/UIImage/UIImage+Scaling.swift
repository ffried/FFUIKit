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

import UIKit

extension UIImage {
    public final func scaled(to size: CGSize) -> UIImage {
#if os(watchOS)
        func _legacyScaling() -> UIImage {
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            defer { UIGraphicsEndImageContext() }
            draw(in: CGRect(origin: .zero, size: size))
            return UIGraphicsGetImageFromCurrentImageContext() ?? self
        }
        return _legacyScaling()
#else
        let format = UIGraphicsImageRendererFormat.osPreferred()
        format.opaque = !hasAlpha
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in draw(in: CGRect(origin: .zero, size: size)) }
#endif
    }
}
