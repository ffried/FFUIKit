//
//  NotificationController.swift
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

import struct Foundation.TimeInterval
import class Foundation.NSCoder
import protocol UIKit.UIViewControllerTransitioningDelegate
import protocol UIKit.UIViewControllerAnimatedTransitioning
import enum UIKit.UIStatusBarAnimation
import enum UIKit.UIStatusBarStyle
import enum UIKit.UIModalPresentationStyle
import class UIKit.UIView
import class UIKit.UITapGestureRecognizer
import class UIKit.UIViewController
import class UIKit.UIPresentationController
import typealias FFFoundation.AnyTimer

internal protocol NotificationControllerProtocol: class {
    var noteView: NotificationView { get }

    func dismissNotification(animated: Bool, completion: (() -> ())?)
}

public final class NotificationController<View: NotificationView>: UIViewController, UIViewControllerTransitioningDelegate, NotificationControllerProtocol {
    
    public enum AutoDismissType {
        case none
        case afterDuration(TimeInterval)
    }
    
    public let notificationView: View = View()
    var noteView: NotificationView { return notificationView }
    
    public var style: NotificationStyle {
        didSet {
            notificationView.configure(for: style)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapNotification(_:)))
    
    public var dismissOnTap: Bool {
        get { return tapGestureRecognizer.isEnabled }
        set { tapGestureRecognizer.isEnabled = newValue }
    }
    
    public let autoDismissType: AutoDismissType
    private lazy var timer: AnyTimer? = {
        switch autoDismissType {
        case .none:
            return nil
        case .afterDuration(let duration):
            let timer = AnyTimer(interval: duration) { [unowned self] _ in
                self.dismissNotification()
            }
            timer.tolerance = 0.5
            return timer
        }
    }()
    
    // MARK: - Initalizer
    public init(style: NotificationStyle = .default, autoDismissType: AutoDismissType = .none) {
        self.style = style
        self.autoDismissType = autoDismissType
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        style = .default
        autoDismissType = .none
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.enableAutoLayout()
        view.backgroundColor = .clear
        notificationView.addGestureRecognizer(tapGestureRecognizer)
        notificationView.configure(for: style)
        notificationView.setupFullscreen(in: view)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationView._willAppear(animated: animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notificationView._didAppear(animated: animated)
        timer?.schedule()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationView._willDisappear(animated: animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationView._didDisappear(animated: animated)
    }
    
    // MARK: - Status Bar
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return (notificationView.backgroundView.backgroundColor?.hsbaComponents?.isDarkColor ?? false) ? .lightContent : .default
    }
    
    // MARK: - Actions
    @objc dynamic internal func didTapNotification(_ recognizer: UITapGestureRecognizer) {
        notificationView._didReceiveTouch(sender: recognizer)
        dismissNotification()
    }
    
    public final func dismissNotification(animated: Bool = true, completion: (() -> ())? = nil) {
        timer?.invalidate()
        presentingViewController?.dismiss(animated: animated, completion: completion)
    }
    
    public final func presentNotification(from source: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        let presentationBlock = {
            source.present(self, animated: animated, completion: completion)
        }
        // We need to cast to the protocol instead of the class, because a different NotificationView could be used.
        if let note = source.presentedViewController as? NotificationControllerProtocol {
            note.dismissNotification(animated: animated, completion: presentationBlock)
        } else {
            presentationBlock()
        }
    }
    
    // MARK: - Transitioning
    private lazy var animationController = NotificationAnimationController()
    
    public override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { return self }
        set { /* NoOp */ }
    }
    
    public override var modalPresentationStyle: UIModalPresentationStyle {
        get { return .custom }
        set { /* NoOp */ }
    }
    
    @objc(animationControllerForPresentedController:presentingController:sourceController:)
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: Can this be replaced with `presented === self`?
        if presented is NotificationControllerProtocol {
            return animationController
        }
        return nil
    }
    
    @objc(animationControllerForDismissedController:)
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: Can this be replaced with `dismissed === self`?
        if dismissed is NotificationControllerProtocol {
            return animationController
        }
        return nil
    }
    
    @objc(presentationControllerForPresentedViewController:presentingViewController:sourceViewController:)
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        // TODO: Can this be replaced with `presented === self`?
        if presented is NotificationControllerProtocol {
            return NotificationPresentationController(presentedViewController: presented, presenting:  presenting)
        }
        return nil
    }
}
