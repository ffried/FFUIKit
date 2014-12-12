//
//  FFLabel.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 9.12.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

import FFUIKit

@IBDesignable
public class FFLabel: UILabel {
    @IBInspectable public var edgeInsets = UIEdgeInsetsZero
    
    public override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.width += edgeInsets.left + edgeInsets.right
        size.height += edgeInsets.top + edgeInsets.bottom
        return size
    }
}
