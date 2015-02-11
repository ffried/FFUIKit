//
//  LayoutGuide.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 11.2.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFUIKit

public class LayoutGuide: NSObject, UILayoutSupport {
    public private(set) var length: CGFloat
    
    public required init(length: CGFloat = 0.0) {
        self.length = length
        super.init()
    }
    
    override convenience init() { self.init(length: 0.0) }
}
