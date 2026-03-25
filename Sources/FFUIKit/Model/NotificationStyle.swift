//
//  NotificationStyle.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 14/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

public import UIKit

public enum NotificationStyle: Sendable, Hashable {
    case `default` // White
    case warning // Yellow
    case failure // Red
    case success // Green
    case info    // Blue
    case custom // Whatever you like

    public var suggestedBackgroundColor: UIColor {
        let alpha: CGFloat = 0.85
        return switch self {
        case .default: UIColor.lightGray.withAlphaComponent(alpha)
        case .warning: UIColor.yellow.withAlphaComponent(alpha)
        case .failure: UIColor.red.withAlphaComponent(alpha)
        case .success: UIColor.green.withAlphaComponent(alpha)
        case .info: UIColor.blue.withAlphaComponent(alpha)
        case .custom: .white
        }
    }

    public var suggestedTextColor: UIColor {
        switch self {
        case .default: .black
        case .warning: .black
        case .failure: .white
        case .success: .black
        case .info: .white
        case .custom: .black
        }
    }
}
