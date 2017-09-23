//
//  TextNotificationView.swift
//  FFUIKit
//
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

import class Foundation.NSCoder
import struct CoreGraphics.CGRect
import class UIKit.UIView
import class UIKit.UILabel
import FFFoundation

public final class TextNotificationView: NotificationView {
    public let textLabel: UILabel = {
        let label = UILabel()
        label.enableAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    private final func initialize() {
        contentView.addSubview(textLabel)
        let views = ["label": textLabel]
        ["H:|-15-[label]-15-|", "V:|-5-[label]-5-|"].constraints(with: views).activate()
    }
}
