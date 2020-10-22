//
//  NotificationPresentationController.swift
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

#if !os(watchOS)
import struct CoreGraphics.CGRect
import class UIKit.UIPresentationController

final class NotificationPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        presentedView?.layoutIfNeeded()
        return presentedView?.bounds ?? .zero
    }

    override var shouldPresentInFullscreen: Bool { false }
    override var shouldRemovePresentersView: Bool { false }
}
#endif
