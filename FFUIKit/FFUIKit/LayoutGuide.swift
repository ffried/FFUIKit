//
//  LayoutGuide.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 11.2.15.
//  Copyright 2015 Florian Friedrich
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

import class Foundation.NSObject
import UIKit

@available(iOS, introduced: 7.0)
public final class LayoutGuide: NSObject, UILayoutSupport {
    public private(set) var length: CGFloat
    
    public private(set) var originalGuide: UILayoutSupport
    public required init(originalGuide: UILayoutSupport, length: CGFloat = 0.0) {
        self.originalGuide = originalGuide
        self.length = length
        super.init()
    }
    
    @available(iOS 9.0, *)
    public var topAnchor: NSLayoutYAxisAnchor {
        return originalGuide.topAnchor
    }
    
    @available(iOS 9.0, *)
    public var bottomAnchor: NSLayoutYAxisAnchor {
        return originalGuide.bottomAnchor
    }
    
    @available(iOS 9.0, *)
    public var heightAnchor: NSLayoutDimension {
        return originalGuide.heightAnchor
    }
}
