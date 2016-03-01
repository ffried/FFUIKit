//
//  UIImageView+AnimatedImageChange.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24/02/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public extension UIImageView {
    public final func setImage(image: UIImage?, animated: Bool, animationDuration: NSTimeInterval = 1.0) {
        let change: () -> () = {
            self.image = image
        }
        if !animated {
            change()
        } else {
            let options: UIViewAnimationOptions = [.TransitionCrossDissolve, .BeginFromCurrentState, .AllowUserInteraction]
            UIView.transitionWithView(self, duration: animationDuration, options: options, animations: change, completion: nil)
        }
    }
}
