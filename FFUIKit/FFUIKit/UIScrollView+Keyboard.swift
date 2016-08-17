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
    #if swift(>=3.0)
    private typealias UserInfoDictionary = [AnyHashable: AnyObject]
    #else
    private typealias UserInfoDictionary = [String: AnyObject]
    #endif
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
        #if swift(>=3.0)
            func block(for selector: @escaping (UserInfoDictionary) -> ()) -> NotificationObserver.ObserverBlock {
                return { note in if let userInfo = note.userInfo as? UserInfoDictionary { selector(userInfo) } }
            }
        
            let center = NotificationCenter.default
            let queue = OperationQueue.main
            let tuples = [
                (NSNotification.Name.UIKeyboardWillChangeFrame, block(for: keyboardWillChangeFrame)),
                (NSNotification.Name.UIKeyboardWillShow, block(for: keyboardWillShow)),
                (NSNotification.Name.UIKeyboardDidHide, block(for: keyboardDidHide))
            ]
        #else
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
        #endif
        
        for (name, block) in tuples {
            notificationObservers.append(NotificationObserver(center: center, name: name, queue: queue, object: nil, block: block))
        }
    }
    
    #if swift(>=3.0)
    @available(*, deprecated, message: "Use unregisterFromKeyboardNotifications.", renamed: "unregisterFromKeyboardNotifications")
    public final func unregisterForKeyboardNotifications() {
        unregisterFromKeyboardNotifications()
    }
    #else
    @available(*, deprecated, message="Use unregisterFromKeyboardNotifications.", renamed="unregisterFromKeyboardNotifications")
    public final func unregisterForKeyboardNotifications() {
        unregisterFromKeyboardNotifications()
    }
    #endif
    
    public final func unregisterFromKeyboardNotifications() {
        #if swift(>=3.0)
            notificationObservers.removeAll(keepingCapacity: false)
        #else
            notificationObservers.removeAll(keepCapacity: false)
        #endif
    }
    
    // MARK: Keyboard functions
    private final func keyboardWillChangeFrame(userInfo: UserInfoDictionary) {
        if keyboardVisible {
            #if swift(>=3.0)
                let beginFrame = rect(for: UIKeyboardFrameBeginUserInfoKey, in: userInfo)
                let endFrame = rect(for: UIKeyboardFrameEndUserInfoKey, in: userInfo)
                let oldHeight = keyboardHeight(from: beginFrame)
                let newHeight = keyboardHeight(from: endFrame)
                if newHeight != oldHeight {
                    setInsetsTo(keyboardHeight: newHeight, animated: true, withKeyboardUserInfo: userInfo)
                }
            #else
                let beginFrame = rectForKey(UIKeyboardFrameBeginUserInfoKey, inUserInfo: userInfo)
                let endFrame = rectForKey(UIKeyboardFrameEndUserInfoKey, inUserInfo: userInfo)
                let oldHeight = keyboardHeightFromRect(beginFrame)
                let newHeight = keyboardHeightFromRect(endFrame)
                if newHeight != oldHeight {
                    setInsetsToKeyboardHeight(newHeight, animated: true, withKeyboardUserInfo: userInfo)
                }
            #endif
        }
    }
    
    private final func keyboardWillShow(userInfo: UserInfoDictionary) {
        if !keyboardVisible {
            saveEdgeInsets()
            keyboardVisible = true
            #if swift(>=3.0)
                let endFrame = rect(for: UIKeyboardFrameEndUserInfoKey, in: userInfo)
                let endHeight = keyboardHeight(from: endFrame)
                setInsetsTo(keyboardHeight: endHeight, animated: true, withKeyboardUserInfo: userInfo)
            #else
                let endFrame = rectForKey(UIKeyboardFrameEndUserInfoKey, inUserInfo: userInfo)
                let endHeight = keyboardHeightFromRect(endFrame)
                setInsetsToKeyboardHeight(endHeight, animated: true, withKeyboardUserInfo: userInfo)
            #endif
        }
    }
    
    private final func keyboardDidHide(userInfo: UserInfoDictionary) {
        if keyboardVisible {
            keyboardVisible = false
            restoreEdgeInsets(animated: true, userInfo: userInfo)
        }
    }
    
    // MARK: Height Adjustments
    #if swift(>=3.0)
    private final func setInsetsTo(keyboardHeight height: CGFloat, animated: Bool = false, withKeyboardUserInfo userInfo: UserInfoDictionary? = nil) {
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
            if let fr = findFirstResponder(in: self) as? UIView {
                let respFrame = self.convert(fr.frame, from: fr.superview)
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
    #else
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
    #endif
    
    // MARK: EdgeInsets
    private final func saveEdgeInsets() {
        originalContentInsets = contentInset
        originalScrollIndicatorInsets = scrollIndicatorInsets
    }
    
    #if swift(>=3.0)
    private final func restoreEdgeInsets(animated: Bool = false, userInfo: UserInfoDictionary? = nil) {
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
    #else
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
    #endif
    
    // MARK: Helpers
    #if swift(>=3.0)
    private final func rect(for key: String, in userInfo: UserInfoDictionary) -> CGRect {
        return (userInfo[key] as? NSValue)?.cgRectValue ?? CGRect.zero
    }
    
    private final func keyboardHeight(from rect: CGRect) -> CGFloat {
        var height: CGFloat = 0.0
        if let w = window {
            let windowFrame = w.convert(bounds, from: self)
            let keyboardFrame = windowFrame.intersection(rect)
            let coveredFrame = w.convert(keyboardFrame, to: self)
            height = coveredFrame.size.height
        }
        return height
    }
    
    private final func animate(_ animations: @escaping () -> (), withKeyboardUserInfo userInfo: UserInfoDictionary? = nil, completion: (@escaping (_ finished: Bool) -> ())? = nil) {
        var duration: TimeInterval = 1.0 / 3.0
        var curve: UIViewAnimationCurve = .linear
        let options: UIViewAnimationOptions = [.beginFromCurrentState, .allowAnimatedContent, .allowUserInteraction]
        if let info = userInfo {
            if let d = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval { duration = d }
            if let c = UIViewAnimationCurve(rawValue: (info[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve.RawValue ?? curve.rawValue)) { curve = c }
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            UIView.setAnimationCurve(curve)
            animations()
            }, completion: completion)
    }
    #else
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
    #endif
}

private var _UIScrollViewOriginalContentInsetsKey = "OriginalContentInsets"
private var _UIScrollViewOriginalScrollIndicatorInsetsKey = "OriginalScrollIndicatorInsets"
private var _UIScrollViewKeyboardVisibleKey = "KeyboardVisible"
#if swift(>=3.0)
fileprivate extension UIScrollView {
    fileprivate final var originalContentInsets: UIEdgeInsets {
        get {
            return (objc_getAssociatedObject(self, &_UIScrollViewOriginalContentInsetsKey) as? NSValue)?.uiEdgeInsetsValue ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &_UIScrollViewOriginalContentInsetsKey, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate final var originalScrollIndicatorInsets: UIEdgeInsets {
        get {
            return (objc_getAssociatedObject(self, &_UIScrollViewOriginalScrollIndicatorInsetsKey) as? NSValue)?.uiEdgeInsetsValue ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &_UIScrollViewOriginalScrollIndicatorInsetsKey, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate final var keyboardVisible: Bool {
        get {
            return (objc_getAssociatedObject(self, &_UIScrollViewKeyboardVisibleKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &_UIScrollViewKeyboardVisibleKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
#else
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
#endif
