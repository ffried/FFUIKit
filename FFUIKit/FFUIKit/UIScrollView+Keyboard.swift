//
//  UIScrollView+Keyboard.swift
//  FFUIkit
//
//  Created by Florian Friedrich on 20.2.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import UIKit
import FFFoundation
import ObjectiveC

private var _UIScrollViewNotificationObservers = [NotificationObserver]()
public extension UIScrollView {
    private typealias UserInfoDictionary = [String: AnyObject]
    private var notificationObservers: [NotificationObserver] {
        get { return _UIScrollViewNotificationObservers }
        set { _UIScrollViewNotificationObservers = newValue }
    }
    
    // MARK: Register / Unregister
    public func registerForKeyboardNotifications() {
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
    
    public func unregisterForKeyboardNotifications() {
        notificationObservers.removeAll(keepCapacity: false)
    }
    
    // MARK: Keyboard functions
    private func keyboardWillChangeFrame(userInfo: UserInfoDictionary) {
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
    
    private func keyboardWillShow(userInfo: UserInfoDictionary) {
        if !keyboardVisible {
            saveEdgeInsets()
            keyboardVisible = true
            let endFrame = rectForKey(UIKeyboardFrameEndUserInfoKey, inUserInfo: userInfo)
            let endHeight = keyboardHeightFromRect(endFrame)
            setInsetsToKeyboardHeight(endHeight, animated: true, withKeyboardUserInfo: userInfo)
        }
    }
    
    private func keyboardDidHide(userInfo: UserInfoDictionary) {
        if keyboardVisible {
            keyboardVisible = false
            restoreEdgeInsets(animated: true, userInfo: userInfo)
        }
    }
    
    // MARK: Height Adjustments
    private func setInsetsToKeyboardHeight(height: CGFloat, animated: Bool = false, withKeyboardUserInfo userInfo: UserInfoDictionary? = nil) {
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
    private func saveEdgeInsets() {
        originalContentInsets = contentInset
        originalScrollIndicatorInsets = scrollIndicatorInsets
    }
    
    private func restoreEdgeInsets(animated animated: Bool = false, userInfo: UserInfoDictionary? = nil) {
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
    private func rectForKey(key: String, inUserInfo userInfo: UserInfoDictionary) -> CGRect {
        return (userInfo[key] as? NSValue)?.CGRectValue() ?? CGRectZero
    }
    
    private func keyboardHeightFromRect(rect: CGRect) -> CGFloat {
        var height: CGFloat = 0.0
        if let w = window {
            let windowFrame = w.convertRect(bounds, fromView: self)
            let keyboardFrame = CGRectIntersection(windowFrame, rect)
            let coveredFrame = w.convertRect(keyboardFrame, toView: self)
            height = coveredFrame.size.height
        }
        return height
    }
    
    private func animate(animations: () -> (), withKeyboardUserInfo userInfo: UserInfoDictionary? = nil, completion: ((finished: Bool) -> ())? = nil) {
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
    private var originalContentInsets: UIEdgeInsets {
        get {
            return (objc_getAssociatedObject(self, &_UIScrollViewOriginalContentInsetsKey) as? NSValue)?.UIEdgeInsetsValue() ?? UIEdgeInsetsZero
        }
        set {
            objc_setAssociatedObject(self, &_UIScrollViewOriginalContentInsetsKey, NSValue(UIEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var originalScrollIndicatorInsets: UIEdgeInsets {
        get {
            return (objc_getAssociatedObject(self, &_UIScrollViewOriginalScrollIndicatorInsetsKey) as? NSValue)?.UIEdgeInsetsValue() ?? UIEdgeInsetsZero
        }
        set {
            objc_setAssociatedObject(self, &_UIScrollViewOriginalScrollIndicatorInsetsKey, NSValue(UIEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var keyboardVisible: Bool {
        get {
            return (objc_getAssociatedObject(self, &_UIScrollViewKeyboardVisibleKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &_UIScrollViewKeyboardVisibleKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
