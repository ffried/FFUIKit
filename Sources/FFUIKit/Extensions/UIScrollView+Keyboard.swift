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

#if !os(watchOS)
import enum ObjectiveC.objc_AssociationPolicy
import func ObjectiveC.objc_getAssociatedObject
import func ObjectiveC.objc_setAssociatedObject
import Foundation
import UIKit

private var _keyboardNotificationObserversKey = "KeyboardNotificationsObserver"
@available(tvOS, unavailable)
extension UIScrollView {
    private typealias UserInfoDictionary = Dictionary<AnyHashable, Any>
    
    private final var notificationObservers: Array<any NSObjectProtocol> {
        get {
            guard let observers = withUnsafePointer(to: &_keyboardNotificationObserversKey, { objc_getAssociatedObject(self, $0) }) as? Array<any NSObjectProtocol>
            else { return [] }
            return observers
        }
        set {
            withUnsafePointer(to: &_keyboardNotificationObserversKey) {
                objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
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
        guard keyboardVisible else { return }
        let beginFrame = rect(for: UIResponder.keyboardFrameBeginUserInfoKey, in: userInfo)
        let endFrame = rect(for: UIResponder.keyboardFrameEndUserInfoKey, in: userInfo)
        let oldHeight = keyboardHeight(from: beginFrame)
        let newHeight = keyboardHeight(from: endFrame)
        if newHeight != oldHeight {
            setInsetsTo(keyboardHeight: newHeight, animated: true, withKeyboardUserInfo: userInfo)
        }
    }
    
    private final func keyboardWillShow(userInfo: UserInfoDictionary) {
        guard !keyboardVisible else { return }
        saveEdgeInsets()
        keyboardVisible = true
        let endFrame = rect(for: UIResponder.keyboardFrameEndUserInfoKey, in: userInfo)
        let endHeight = keyboardHeight(from: endFrame)
        setInsetsTo(keyboardHeight: endHeight, animated: true, withKeyboardUserInfo: userInfo)
    }
    
    private final func keyboardDidHide(userInfo: UserInfoDictionary) {
        guard keyboardVisible else { return }
        keyboardVisible = false
        restoreEdgeInsets(animated: true, userInfo: userInfo)
    }
    
    // MARK: Height Adjustments
    private final func setInsetsTo(keyboardHeight height: CGFloat, animated: Bool = false, withKeyboardUserInfo userInfo: UserInfoDictionary? = nil) {
        let changes: () -> () = {
            self.contentInset.bottom = height
            if #available(iOS 11.1, tvOS 11.1, macCatalyst 13.0, *) {
                self.horizontalScrollIndicatorInsets.bottom = height
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
        if #available(iOS 11.1, tvOS 11.1, macCatalyst 13.0, *) {
            originalHorizontalScrollIndicatorInsets = horizontalScrollIndicatorInsets
            originalVerticalScrollIndicatorInsets = verticalScrollIndicatorInsets
        } else {
            originalScrollIndicatorInsets = scrollIndicatorInsets
        }
    }
    
    private final func restoreEdgeInsets(animated: Bool = false, userInfo: UserInfoDictionary? = nil) {
        let changes: () -> () = {
            self.contentInset = self.originalContentInsets
            if #available(iOS 11.1, tvOS 11.1, macCatalyst 13.0, *) {
                self.horizontalScrollIndicatorInsets = self.originalHorizontalScrollIndicatorInsets
                self.verticalScrollIndicatorInsets = self.originalVerticalScrollIndicatorInsets
            } else {
                self.scrollIndicatorInsets = self.originalScrollIndicatorInsets
            }
        }
        if animated {
            animate(changes, withKeyboardUserInfo: userInfo)
        } else {
            changes()
        }
    }
    
    // MARK: Helpers
    private final func rect(for key: String, in userInfo: UserInfoDictionary) -> CGRect {
        (userInfo[key] as? NSValue)?.cgRectValue ?? .zero
    }
    
    private final func keyboardHeight(from rect: CGRect) -> CGFloat {
        guard let w = window else { return 0 }
        let windowFrame = w.convert(bounds, from: self)
        let keyboardFrame = windowFrame.intersection(rect)
        let coveredFrame = w.convert(keyboardFrame, to: self)
        return coveredFrame.size.height
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
            assert(UIView.AnimationOptions.curveEaseIn.rawValue == UInt(UIView.AnimationCurve.easeIn.rawValue) << 16)
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
private var _originalHorizontalScrollIndicatorInsetsKey = "OriginalHorizontalScrollIndicatorInsets"
private var _originalVerticalScrollIndicatorInsetsKey = "OriginalVerticalScrollIndicatorInsets"
private var _keyboardVisibleKey = "KeyboardVisible"
fileprivate extension UIScrollView {
    private func edgeInsets(forKey key: UnsafeRawPointer) -> UIEdgeInsets? {
        (objc_getAssociatedObject(self, key) as? NSValue)?.uiEdgeInsetsValue
    }

    private func setEdgeInsets(_ edgeInsets: UIEdgeInsets?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, edgeInsets.map(NSValue.init(uiEdgeInsets:)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    final var originalContentInsets: UIEdgeInsets {
        get { withUnsafePointer(to: &_originalContentInsetsKey) { edgeInsets(forKey: $0) } ?? .zero }
        set { withUnsafePointer(to: &_originalContentInsetsKey) { setEdgeInsets(newValue, forKey: $0) } }
    }
    
    final var originalScrollIndicatorInsets: UIEdgeInsets {
        get { withUnsafePointer(to: &_originalScrollIndicatorInsetsKey) { edgeInsets(forKey: $0) } ?? .zero }
        set { withUnsafePointer(to: &_originalScrollIndicatorInsetsKey) { setEdgeInsets(newValue, forKey: $0) } }
    }

    final var originalHorizontalScrollIndicatorInsets: UIEdgeInsets {
        get { withUnsafePointer(to: &_originalHorizontalScrollIndicatorInsetsKey) { edgeInsets(forKey: $0) } ?? .zero }
        set { withUnsafePointer(to: &_originalHorizontalScrollIndicatorInsetsKey) { setEdgeInsets(newValue, forKey: $0) } }
    }

    final var originalVerticalScrollIndicatorInsets: UIEdgeInsets {
        get { withUnsafePointer(to: &_originalVerticalScrollIndicatorInsetsKey) { edgeInsets(forKey: $0) } ?? .zero }
        set { withUnsafePointer(to: &_originalVerticalScrollIndicatorInsetsKey) { setEdgeInsets(newValue, forKey: $0) } }
    }
    
    final var keyboardVisible: Bool {
        get { withUnsafePointer(to: &_keyboardVisibleKey) { objc_getAssociatedObject(self, $0) as? Bool } ?? false }
        set { withUnsafePointer(to: &_keyboardVisibleKey) { objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_ASSIGN) } }
    }
}
#endif
