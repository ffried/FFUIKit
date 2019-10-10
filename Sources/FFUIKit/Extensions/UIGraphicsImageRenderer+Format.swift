//
//  UIGraphicsImageRenderer+Format.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 10.10.19.
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

#if !os(watchOS)
import class UIKit.UIGraphicsImageRendererFormat

extension UIGraphicsImageRendererFormat {
    @inlinable
    static func osPreferred() -> UIGraphicsImageRendererFormat {
        if #available(iOS 11, tvOS 11, *) {
            return .preferred()
        } else {
            return .default()
        }
    }
}
#endif
