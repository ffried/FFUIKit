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

import UIKit
import FFFoundation

public enum NotificationAutoDismissType {
#if swift(>=3.0)
    case none
    case afterDuration(TimeInterval)
#else
    case None
    case AfterDuration(duration: NSTimeInterval)
#endif
}

public final class NotificationController<NotificationView: NotificationViewType where NotificationView: UIView>: UIViewController, UIViewControllerTransitioningDelegate {
    #if swift(>=3.0)
    public typealias `Type` = NotificationType<NotificationView>
    #else
    public typealias Type = NotificationType<NotificationView>
    #endif
    
    public let notificationView: NotificationView = NotificationView()
    private var informedNotificationView: InformedNotificationViewType? {
        return notificationView as? InformedNotificationViewType
    }
    
    public var notificationType: Type {
        didSet {
            #if swift(>=3.0)
                notificationType.configure(notificationView: notificationView)
            #else
                notificationType.configureNotificationView(notificationView)
            #endif
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        #if swift(>=2.2)
            recognizer.addTarget(self, action: #selector(NotificationController.didTapNotification(_:)))
        #else
            recognizer.addTarget(self, action: "didTapNotification:")
        #endif
        return recognizer
    }()
    
    #if swift(>=3.0)
    public var dismissOnTap: Bool {
        get { return tapGestureRecognizer.isEnabled }
        set { tapGestureRecognizer.isEnabled = newValue }
    }
    #else
    public var dismissOnTap: Bool {
        get { return tapGestureRecognizer.enabled }
        set { tapGestureRecognizer.enabled = newValue }
    }
    #endif
    
    public let autoDismissType: NotificationAutoDismissType
    private lazy var timer: AnyTimer? = {
        #if swift(>=3.0)
            switch self.autoDismissType {
            case .none:
                return nil
            case .afterDuration(let duration):
                let timer = AnyTimer(interval: duration) { [unowned self] timer in
                    self.dismissNotification()
                }
                timer.tolerance = 0.5
                return timer
            }
        #else
            switch self.autoDismissType {
            case .None: return nil
            case .AfterDuration(let duration):
                let timer = AnyTimer(interval: duration) { [unowned self] timer in
                    self.dismissNotification()
                }
                timer.tolerance = 0.5
                return timer
            }
        #endif
    }()
    
    // MARK: - Initalizer
    #if swift(>=3.0)
    public init(type: Type = .default, autoDismissType: NotificationAutoDismissType = .none) {
        notificationType = type
        self.autoDismissType = autoDismissType
        super.init(nibName: nil, bundle: nil)
    }
    #else
    public init(type: Type = .Default, autoDismissType: NotificationAutoDismissType = .None) {
        notificationType = type
        self.autoDismissType = autoDismissType
        super.init(nibName: nil, bundle: nil)
    }
    #endif

    required public init?(coder aDecoder: NSCoder) {
        #if swift(>=3.0)
            notificationType = .default
            autoDismissType = .none
        #else
            notificationType = .Default
            autoDismissType = .None
        #endif
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        #if swift(>=3.0)
            view.backgroundColor = .clear
            notificationType.configure(notificationView: notificationView)
            notificationView.addGestureRecognizer(tapGestureRecognizer)
            notificationView.setupFullscreen(in: view)
        #else
            view.backgroundColor = .clearColor()
            notificationType.configureNotificationView(notificationView)
            notificationView.addGestureRecognizer(tapGestureRecognizer)
            notificationView.setupFullscreenInView(view)
        #endif
    }
    
    #if swift(>=3.0)
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        informedNotificationView?.willAppear(animated: animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        informedNotificationView?.didAppear(animated: animated)
        timer?.schedule()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        informedNotificationView?.willDisappear(animated: animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        informedNotificationView?.didDisappear(animated: animated)
    }
    
    // MARK: - Status Bar
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return (notificationView.backgroundColor?.components?.isDarkColor ?? false) ? .lightContent : .default
    }
    #else
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        informedNotificationView?.willAppear(animated)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        informedNotificationView?.didAppear(animated)
        timer?.schedule()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        informedNotificationView?.willDisappear(animated)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        informedNotificationView?.didDisappear(animated)
    }
    
    // MARK: - Status Bar
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return (notificationView.backgroundColor?.components?.isDarkColor ?? false) ? .LightContent : .Default
    }
    #endif
    
    #if swift(>=3.0)
    // MARK: - Actions
    @objc internal func didTapNotification(_ recognizer: UITapGestureRecognizer) {
        dismissNotification()
    }
    #else
    // MARK: - Actions
    @objc internal func didTapNotification(recognizer: UITapGestureRecognizer) {
        dismissNotification()
    }
    #endif
    
    public final func dismissNotification(animated: Bool = true, completion: (() -> ())? = nil) {
        timer?.invalidate()
        #if swift(>=3.0)
            presentingViewController?.dismiss(animated: animated, completion: completion)
        #else
            presentingViewController?.dismissViewControllerAnimated(animated, completion: completion)
        #endif
    }
    
    #if swift(>=3.0)
    public final func presentNotification(from source: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        let presentationBlock = {
            source.present(self, animated: animated, completion: completion)
        }
        if let note = source.presentedViewController as? NotificationController {
            note.dismissNotification(animated: animated, completion: presentationBlock)
        } else {
            presentationBlock()
        }
    }
    #else
    public final func presentNotification(source: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        let presentationBlock = {
            source.presentViewController(self, animated: animated, completion: completion)
        }
        if let note = source.presentedViewController as? NotificationController {
            note.dismissNotification(animated, completion: presentationBlock)
        } else {
            presentationBlock()
        }
    }
    #endif
    
    // MARK: - Transitioning
    private lazy var animationController = NotificationAnimationController()
    
    public override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { return self }
        set {}
    }

    public override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            #if swift(>=3.0)
                return .custom
            #else
                return .Custom
            #endif
        }
        set {}
    }
    
    #if swift(>=3.0)
    @objc public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is NotificationController {
            return animationController
        }
        return nil
    }
    
    @objc public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is NotificationController {
            return animationController
        }
        return nil
    }
    
    @objc public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is NotificationController {
            return NotificationPresentationController(presentedViewController: presented, presenting:  presenting)
        }
        return nil
    }
    #else
    @objc public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is NotificationController {
            return animationController
        }
        return nil
    }
    
    @objc public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is NotificationController {
            return animationController
        }
        return nil
    }
    
    @objc public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        if presented is NotificationController {
            return NotificationPresentationController(presentedViewController: presented, presentingViewController:  presenting)
        }
        return nil
    }
    #endif
}
