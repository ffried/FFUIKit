//
//  NotificationPresentationController.swift
//  NotificationsController
//
//  Created by Florian Friedrich on 13/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

internal class NotificationPresentationController: UIPresentationController {
    internal override func frameOfPresentedViewInContainerView() -> CGRect {
        presentedView()?.layoutIfNeeded()
        return presentedView()?.bounds ?? CGRect.zero
    }
    
    internal override func shouldPresentInFullscreen() -> Bool {
        return false
    }
}
