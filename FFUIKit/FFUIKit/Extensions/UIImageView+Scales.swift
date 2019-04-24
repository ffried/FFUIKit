//
//  UIImageView+Scales.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 08.01.19.
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

import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGSize
import class UIKit.UIImageView

extension UIImageView {
    private func scale(using dimensionPath: KeyPath<CGSize, CGFloat>) -> CGFloat {
        guard let image = image else { return 0 }
        return bounds.size[keyPath: dimensionPath] / image.size[keyPath: dimensionPath]
    }

    /// Returns the current horizontal (zoom) scale of the image compared to the image view.
    /// E.g. if the image has a size of 100x50, but the image view is only sized at 50x25, this will return 0.5.
    /// If there's no image, 0 is returned.
    public var horizontalScale: CGFloat { return scale(using: \.width) }

    /// Returns the current vertical (zoom) scale of the image compared to the image view.
    /// E.g. if the image has a size of 100x50, but the image view is only sized at 50x25, this will return 0.5.
    /// If there's no image, 0 is returned.
    public var verticalScale: CGFloat { return scale(using: \.height) }
}
