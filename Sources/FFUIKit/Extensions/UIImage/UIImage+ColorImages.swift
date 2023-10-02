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

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize) {
        let image: UIImage?
#if os(watchOS)
        func _legacyDrawing() -> UIImage? {
            UIGraphicsBeginImageContext(size)
            defer { UIGraphicsEndImageContext() }
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(color.cgColor)
            context?.fill(CGRect(origin: .zero, size: size))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        image = _legacyDrawing()
#else
        let renderer = UIGraphicsImageRenderer(size: size)
        image = renderer.image {
            $0.cgContext.setFillColor(color.cgColor)
            $0.cgContext.fill(CGRect(origin: .zero, size: size))
        }
#endif
        if let cgimage = image?.cgImage {
            self.init(cgImage: cgimage)
        } else {
            return nil
        }
    }
}
