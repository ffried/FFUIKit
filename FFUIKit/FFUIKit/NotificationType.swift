//
//  NotificationType.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 14/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public enum NotificationType<NotificationView: NotificationViewType where NotificationView: UIView> {
    #if swift(>=3.0)
    case `default` // White
    case warning // Yellow
    case failure // Red
    case success // Green
    case info    // Blue
    case custom(viewConfiguration: (NotificationView) -> Void) // Whatever you like
    #else
    case Default // White
    case Warning // Yellow
    case Failure // Red
    case Success // Green
    case Info    // Blue
    case Custom(viewConfiguration: (NotificationView) -> Void) // Whatever you like
    #endif
    
    internal func configureNotificationView(view: NotificationView) {
        let backgroundColor: UIColor
        let textColor: UIColor
        let alpha: CGFloat = 0.85
        #if swift(>=3.0)
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
            if case NotificationType.custom(let configuration) = self {
                configuration(view)
            } else {
                view.backgroundColor = backgroundColor
                if let textNotificationView = view as? TextNotificationView {
                    textNotificationView.textLabel.textColor = textColor
                }
            }
        #else
            switch self {
            case .Default:
                backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(alpha)
                textColor = .blackColor()
            case .Warning:
                backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(alpha)
                textColor = UIColor.blackColor()
            case .Failure:
                backgroundColor = UIColor.redColor().colorWithAlphaComponent(alpha)
                textColor = UIColor.whiteColor()
            case .Success:
                backgroundColor = UIColor.greenColor().colorWithAlphaComponent(alpha)
                textColor = UIColor.blackColor()
            case .Info:
                backgroundColor = UIColor.blueColor().colorWithAlphaComponent(alpha)
                textColor = UIColor.whiteColor()
            case .Custom(_):
                backgroundColor = UIColor.clearColor()
                textColor = UIColor.clearColor()
            }
            if case let NotificationType.Custom(configuration) = self {
                configuration(view)
            } else {
                view.backgroundColor = backgroundColor
                if let textNotificationView = view as? TextNotificationView {
                    textNotificationView.textLabel.textColor = textColor
                }
            }
        #endif
    }
}
