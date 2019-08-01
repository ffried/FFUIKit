//
//  UIScrollView+Keyboard.swift
//  FFUIkit
//
//  Created by Florian Friedrich on 20.2.15.
//  Copyright 2015 Florian Friedrich
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

import enum ObjectiveC.objc_AssociationPolicy
import func ObjectiveC.objc_getAssociatedObject
import func ObjectiveC.objc_setAssociatedObject
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGSize
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGRect
import typealias Foundation.TimeInterval
import class Foundation.OperationQueue
import struct Foundation.Notification
import class Foundation.NotificationCenter
import class Foundation.NSValue
import class FFFoundation.NotificationObserver
import struct UIKit.UIEdgeInsets
import enum UIKit.UIViewAnimationCurve
import struct UIKit.UIViewAnimationOptions
import class UIKit.UIView
import class UIKit.UIScrollView

private var _keyboardNotificationObserversKey = "KeyboardNotificationsObserver"
extension UIScrollView {
    private typealias UserInfoDictionary = [AnyHashable: Any]
    
    private final var notificationObservers: [NSObjectProtocol] {
        get {
            guard let observers = objc_getAssociatedObject(self, &_keyboardNotificationObserversKey) as? [NSObjectProtocol] else {
                return []
            }
            return observers
        }
        set { objc_setAssociatedObject(self, &_keyboardNotificationObserversKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: Register / Unregister
    public final func registerForKeyboardNotifications() {
        typealias ObserverBlock = (Notification) -> Void
        func block(for selector: @escaping (UserInfoDictionary) -> ()) -> ObserverBlock {
            return { $0.userInfo.map(selector) }
        }

        let tuples: [(Notification.Name, ObserverBlock)] = [
            (UIResponder.keyboardWillChangeFrameNotification, block(for: keyboardWillChangeFrame)),
            (UIResponder.keyboardWillShowNotification, block(for: keyboardWillShow)),
            (UIResponder.keyboardDidHideNotification, block(for: keyboardDidHide))
        ]
        notificationObservers = tuples.map { NotificationCenter.default.addObserver(forName: $0, object: nil, queue: .main, using: $1) }
    }
    
    public final func unregisterFromKeyboardNotifications() {
        notificationObservers.removeAll()
    }
    
    // MARK: Keyboard functions
    private final func keyboardWillChangeFrame(userInfo: UserInfoDictionary) {
        if keyboardVisible {
            let beginFrame = rect(for: UIResponder.keyboardFrameBeginUserInfoKey, in: userInfo)
            let endFrame = rect(for: UIResponder.keyboardFrameEndUserInfoKey, in: userInfo)
            let oldHeight = keyboardHeight(from: beginFrame)
            let newHeight = keyboardHeight(from: endFrame)
            if newHeight != oldHeight {
                setInsetsTo(keyboardHeight: newHeight, animated: true, withKeyboardUserInfo: userInfo)
            }
        }
    }
    
    private final func keyboardWillShow(userInfo: UserInfoDictionary) {
        if !keyboardVisible {
            saveEdgeInsets()
            keyboardVisible = true
            let endFrame = rect(for: UIResponder.keyboardFrameEndUserInfoKey, in: userInfo)
            let endHeight = keyboardHeight(from: endFrame)
            setInsetsTo(keyboardHeight: endHeight, animated: true, withKeyboardUserInfo: userInfo)
        }
    }
    
    private final func keyboardDidHide(userInfo: UserInfoDictionary) {
        if keyboardVisible {
            keyboardVisible = false
            restoreEdgeInsets(animated: true, userInfo: userInfo)
        }
    }
    
    // MARK: Height Adjustments
    private final func setInsetsTo(keyboardHeight height: CGFloat, animated: Bool = false, withKeyboardUserInfo userInfo: UserInfoDictionary? = nil) {
        let changes: () -> () = {
            self.contentInset.bottom = height
            if #available(iOS 11.1, macCatalyst 13.0, *) {
                self.verticalScrollIndicatorInsets.bottom = height
            } else {
                self.scrollIndicatorInsets.bottom = height
            }
        }
        let offsetChanges: () -> () = {
            if let fr = UIResponder.firstResponder(in: self) as? UIView {
                let respFrame = self.convert(fr.frame, from: fr.superview)
                self.scrollRectToVisible(respFrame, animated: animated)
            }
        }
        if animated {
            animate(changes, withKeyboardUserInfo: userInfo) { _ in offsetChanges() }
        } else {
            changes()
            offsetChanges()
        }
    }
    
    // MARK: EdgeInsets
    private final func saveEdgeInsets() {
        originalContentInsets = contentInset
        if #available(iOS 11.1, macCatalyst 13.0, *) {
            originalScrollIndicatorInsets = verticalScrollIndicatorInsets
        } else {
            originalScrollIndicatorInsets = scrollIndicatorInsets
        }
    }
    
    private final func restoreEdgeInsets(animated: Bool = false, userInfo: UserInfoDictionary? = nil) {
        let changes: () -> () = {
            self.contentInset = self.originalContentInsets
            self.scrollIndicatorInsets = self.originalScrollIndicatorInsets
        }
        if animated {
            animate(changes, withKeyboardUserInfo: userInfo)
        } else {
            changes()
        }
    }
    
    // MARK: Helpers
    private final func rect(for key: String, in userInfo: UserInfoDictionary) -> CGRect {
        return (userInfo[key] as? NSValue)?.cgRectValue ?? .zero
    }
    
    private final func keyboardHeight(from rect: CGRect) -> CGFloat {
        var height: CGFloat = 0
        if let w = window {
            let windowFrame = w.convert(bounds, from: self)
            let keyboardFrame = windowFrame.intersection(rect)
            let coveredFrame = w.convert(keyboardFrame, to: self)
            height = coveredFrame.size.height
        }
        return height
    }
    
    private final func animate(_ animations: @escaping () -> (), withKeyboardUserInfo userInfo: UserInfoDictionary? = nil, completion: ((_ finished: Bool) -> ())? = nil) {
        var duration: TimeInterval = 1 / 3
        var curve: UIView.AnimationCurve = .linear
        let options: UIView.AnimationOptions
        if let info = userInfo {
            if let d = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval { duration = d }
            if let c = UIView.AnimationCurve(rawValue: (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve.RawValue ?? curve.rawValue)) { curve = c }
        }
        if #available(iOS 13, tvOS 13, watchOS 6, macCatalyst 13, *) {
            options = [.beginFromCurrentState, .allowAnimatedContent, .allowUserInteraction, UIView.AnimationOptions(rawValue: UInt(curve.rawValue) << 16)]
        } else {
            options = [.beginFromCurrentState, .allowAnimatedContent, .allowUserInteraction]
        }
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            if #available(iOS 13, tvOS 13, watchOS 6, macCatalyst 13, *) {} else {
                UIView.setAnimationCurve(curve)
            }
            animations()
        }, completion: completion)
    }
}

private var _originalContentInsetsKey = "OriginalContentInsets"
private var _originalScrollIndicatorInsetsKey = "OriginalScrollIndicatorInsets"
private var _keyboardVisibleKey = "KeyboardVisible"
fileprivate extension UIScrollView {
    final var originalContentInsets: UIEdgeInsets {
        get { return (objc_getAssociatedObject(self, &_originalContentInsetsKey) as? NSValue)?.uiEdgeInsetsValue ?? .zero }
        set { objc_setAssociatedObject(self, &_originalContentInsetsKey, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    final var originalScrollIndicatorInsets: UIEdgeInsets {
        get { return (objc_getAssociatedObject(self, &_originalScrollIndicatorInsetsKey) as? NSValue)?.uiEdgeInsetsValue ?? .zero }
        set { objc_setAssociatedObject(self, &_originalScrollIndicatorInsetsKey, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    final var keyboardVisible: Bool {
        get { return (objc_getAssociatedObject(self, &_keyboardVisibleKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &_keyboardVisibleKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}
