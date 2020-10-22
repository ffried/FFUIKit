//
//  TouchAwareControl.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 11.10.17.
//  Copyright © 2017 Florian Friedrich. All rights reserved.
//

#if !os(watchOS)
import UIKit

open class TouchAwareControl: UIControl {
    open private(set) var isTrackingTouchInside = false

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isTrackingTouchInside = super.beginTracking(touch, with: event)
        return isTrackingTouchInside
    }

    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        defer { isTrackingTouchInside = false }
        return super.continueTracking(touch, with: event)
    }

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        isTrackingTouchInside = false
    }
}
#endif
