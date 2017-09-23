//
//  NotificationType.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 14/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import struct CoreGraphics.CGFloat
import class UIKit.UIView
import class UIKit.UIColor

public enum NotificationType<View: NotificationView> {
    
    case `default` // White
    case warning // Yellow
    case failure // Red
    case success // Green
    case info    // Blue
    case custom(viewConfiguration: (View) -> ()) // Whatever you like
    
    internal func configure(notificationView view: View) {
        let backgroundColor: UIColor
        let textColor: UIColor
        let alpha: CGFloat = 0.85
        switch self {
        case .default:
            backgroundColor = UIColor.lightGray.withAlphaComponent(alpha)
            textColor = .black
        case .warning:
            backgroundColor = UIColor.yellow.withAlphaComponent(alpha)
            textColor = .black
        case .failure:
            backgroundColor = UIColor.red.withAlphaComponent(alpha)
            textColor = .white
        case .success:
            backgroundColor = UIColor.green.withAlphaComponent(alpha)
            textColor = .black
        case .info:
            backgroundColor = UIColor.blue.withAlphaComponent(alpha)
            textColor = .white
        case .custom(_):
            backgroundColor = .clear
            textColor = .black
        }
        if case .custom(let configuration) = self {
            configuration(view)
        } else {
            view.backgroundView.backgroundColor = backgroundColor
            if let textNotificationView = view as? TextNotificationView {
                textNotificationView.textLabel.textColor = textColor
            }
        }
    }
}
