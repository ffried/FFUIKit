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

import UIKit
import ObjectiveC
import FFFoundation

private var _UIScrollViewKeyboardNotificationObserversKey = "KeyboardNotificationsObserver"
public extension UIScrollView {
    private typealias UserInfoDictionary = [String: AnyObject]
    private final var notificationObservers: [NotificationObserver] {
        get {
            guard let observers = objc_getAssociatedObject(self, &_UIScrollViewKeyboardNotificationObserversKey) as? [NotificationObserver] else {
                self.notificationObservers = [NotificationObserver]() // Associates them
                return self.notificationObservers // returns the newly associated object
            }
            return observers
        }
        set { objc_setAssociatedObject(self, &_UIScrollViewKeyboardNotificationObserversKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: Register / Unregister
    public final func registerForKeyboardNotifications() {
        func blockForFunc(selector: (userInfo: UserInfoDictionary) -> ()) -> NotificationObserver.ObserverBlock {
            return { note in if let userInfo = note.userInfo as? UserInfoDictionary { selector(userInfo: userInfo) } }
        }
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let tuples = [
            (UIKeyboardWillChangeFrameNotification, blockForFunc(keyboardWillChangeFrame)),
            (UIKeyboardWillShowNotification, blockForFunc(keyboardWillShow)),
            (UIKeyboardDidHideNotification, blockForFunc(keyboardDidHide))
        ]
        for (name, block) in tuples {
            notificationObservers.append(NotificationObserver(center: center, name: name, queue: queue, object: nil, block: block))
        }
    }
    
    public final func unregisterForKeyboardNotifications() {
        notificationObservers.removeAll(keepCapacity: false)
    }
    
    // MARK: Keyboard functions
    private final func keyboardWillChangeFrame(userInfo: UserInfoDictionary) {
        if keyboardVisible {
            let beginFrame = rectForKey(UIKeyboardFrameBeginUserInfoKey, inUserInfo: userInfo)
            let endFrame = rectForKey(UIKeyboardFrameEndUserInfoKey, inUserInfo: userInfo)
            let oldHeight = keyboardHeightFromRect(beginFrame)
            let newHeight = keyboardHeightFromRect(endFrame)
            if newHeight != oldHeight {
                setInsetsToKeyboardHeight(newHeight, animated: true, withKeyboardUserInfo: userInfo)
            }
        }
    }
    
    private final func keyboardWillShow(userInfo: UserInfoDictionary) {
        if !keyboardVisible {
            saveEdgeInsets()
            keyboardVisible = true
            let endFrame = rectForKey(UIKeyboardFrameEndUserInfoKey, inUserInfo: userInfo)
            let endHeight = keyboardHeightFromRect(endFrame)
            setInsetsToKeyboardHeight(endHeight, animated: true, withKeyboardUserInfo: userInfo)
        }
    }
    
    private final func keyboardDidHide(userInfo: UserInfoDictionary) {
        if keyboardVisible {
            keyboardVisible = false
            restoreEdgeInsets(animated: true, userInfo: userInfo)
        }
    }
    
    // MARK: Height Adjustments
    private final func setInsetsToKeyboardHeight(height: CGFloat, animated: Bool = false, withKeyboardUserInfo userInfo: UserInfoDictionary? = nil) {
        let changes: () -> () = {
            var insets: UIEdgeInsets
            
            insets = self.contentInset
            insets.bottom = height
            self.contentInset = insets
            
            insets = self.scrollIndicatorInsets
            insets.bottom = height
            self.scrollIndicatorInsets = insets
        }
        let offsetChanges: () -> () = {
            if let fr = findFirstResponderInView(self) as? UIView {
                let respFrame = self.convertRect(fr.frame, fromView: fr.superview)
                self.scrollRectToVisible(respFrame, animated: animated)
            }
        }
        if animated {
            animate(changes, withKeyboardUserInfo: userInfo) { (finished) in offsetChanges() }
        } else {
            changes()
            offsetChanges()
        }
    }
    
    // MARK: EdgeInsets
    private final func saveEdgeInsets() {
        originalContentInsets = contentInset
        originalScrollIndicatorInsets = scrollIndicatorInsets
    }
    
    private final func restoreEdgeInsets(animated animated: Bool = false, userInfo: UserInfoDictionary? = nil) {
        let changes: () -> () = {
            self.contentInset = self.originalContentInsets
            self.scrollIndicatorInsets = self.originalScrollIndicatorInsets
        }
        if animated {
            animate(changes, withKeyboardUserInfo: userInfo, completion: nil)
        } else {
            changes()
        }
    }
    
    // MARK: Helpers
    private final func rectForKey(key: String, inUserInfo userInfo: UserInfoDictionary) -> CGRect {
        return (userInfo[key] as? NSValue)?.CGRectValue() ?? CGRectZero
    }
    
    private final func keyboardHeightFromRect(rect: CGRect) -> CGFloat {
        var height: CGFloat = 0.0
        if let w = window {
            let windowFrame = w.convertRect(bounds, fromView: self)
            let keyboardFrame = CGRectIntersection(windowFrame, rect)
            let coveredFrame = w.convertRect(keyboardFrame, toView: self)
            height = coveredFrame.size.height
        }
        return height
    }
    
    private final func animate(animations: () -> (), withKeyboardUserInfo userInfo: UserInfoDictionary? = nil, completion: ((finished: Bool) -> ())? = nil) {
        var duration: NSTimeInterval = 1.0/3.0
        var curve: UIViewAnimationCurve = .Linear
        let options: UIViewAnimationOptions = [.BeginFromCurrentState, .AllowAnimatedContent, .AllowUserInteraction]
        if let info = userInfo {
            if let d = info[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval { duration = d }
            if let c = UIViewAnimationCurve(rawValue: (info[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve.RawValue ?? curve.rawValue)) { curve = c }
        }
        UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: {
            UIView.setAnimationCurve(curve)
            animations()
        }, completion: completion)
    }
}

private var _UIScrollViewOriginalContentInsetsKey = "OriginalContentInsets"
private var _UIScrollViewOriginalScrollIndicatorInsetsKey = "OriginalScrollIndicatorInsets"
private var _UIScrollViewKeyboardVisibleKey = "KeyboardVisible"
private extension UIScrollView {
    private final var originalContentInsets: UIEdgeInsets {
        get {
            return (objc_getAssociatedObject(self, &_UIScrollViewOriginalContentInsetsKey) as? NSValue)?.UIEdgeInsetsValue() ?? UIEdgeInsetsZero
        }
        set {
            objc_setAssociatedObject(self, &_UIScrollViewOriginalContentInsetsKey, NSValue(UIEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private final var originalScrollIndicatorInsets: UIEdgeInsets {
        get {
            return (objc_getAssociatedObject(self, &_UIScrollViewOriginalScrollIndicatorInsetsKey) as? NSValue)?.UIEdgeInsetsValue() ?? UIEdgeInsetsZero
        }
        set {
            objc_setAssociatedObject(self, &_UIScrollViewOriginalScrollIndicatorInsetsKey, NSValue(UIEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private final var keyboardVisible: Bool {
        get {
            return (objc_getAssociatedObject(self, &_UIScrollViewKeyboardVisibleKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &_UIScrollViewKeyboardVisibleKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
