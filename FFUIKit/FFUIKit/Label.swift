//
//  Label.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 9.12.14.
//  Copyright 2014 Florian Friedrich
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

@IBDesignable
public class Label: UILabel {
    @IBInspectable public var edgeInsets = UIEdgeInsets() {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    public override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.width += edgeInsets.left + edgeInsets.right
        size.height += edgeInsets.top + edgeInsets.bottom
        return size
    }
}
