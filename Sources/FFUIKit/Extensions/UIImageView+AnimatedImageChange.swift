//
//  UIImageView+AnimatedImageChange.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24/02/16.
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

#if !os(watchOS)
import typealias Foundation.TimeInterval
import class UIKit.UIView
import class UIKit.UIImage
import class UIKit.UIImageView

extension UIImageView {
    public final func setImage(image: UIImage?, animated: Bool, animationDuration: TimeInterval = 1.0) {
        let change: () -> () = {
            self.image = image
        }
        if !animated {
            change()
        } else {
            let options: UIView.AnimationOptions = [.transitionCrossDissolve, .beginFromCurrentState, .allowUserInteraction]
            UIView.transition(with: self, duration: animationDuration, options: options, animations: change, completion: nil)
        }
    }
}
#endif
