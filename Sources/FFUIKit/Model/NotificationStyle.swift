//
//  NotificationStyle.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 14/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import struct CoreGraphics.CGFloat
import class UIKit.UIColor

public enum NotificationStyle {
    case `default` // White
    case warning // Yellow
    case failure // Red
    case success // Green
    case info    // Blue
    case custom // Whatever you like
    
    public var suggestedBackgroundColor: UIColor {
        let alpha: CGFloat = 0.85
        switch self {
        case .default: return UIColor.lightGray.withAlphaComponent(alpha)
        case .warning: return UIColor.yellow.withAlphaComponent(alpha)
        case .failure: return UIColor.red.withAlphaComponent(alpha)
        case .success: return UIColor.green.withAlphaComponent(alpha)
        case .info: return UIColor.blue.withAlphaComponent(alpha)
        case .custom: return .white
        }
    }
    
    public var suggestedTextColor: UIColor {
        switch self {
        case .default: return .black
        case .warning: return .black
        case .failure: return .white
        case .success: return .black
        case .info: return .white
        case .custom: return .black
        }
    }
}

#if compiler(>=5.5.2) && canImport(_Concurrency)
extension NotificationStyle: Sendable {}
#endif
