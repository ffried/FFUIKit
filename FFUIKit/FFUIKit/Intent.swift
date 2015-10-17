//
//  Intent.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 11.12.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

import UIKit

public enum IntentState {
    case New
    case Running
    case Succeeded
    case Failed
    case Cancelled
}

public typealias IntentCompletion = (intent: Intent, state: IntentState) -> ()

private var SelfSustainingIntents = [Intent]()
public class Intent {
    private final var selfSustainingIndex: Int?
    private final var selfSustaining = false
    public final var isSelfSustaining: Bool { return selfSustaining }
    
    public var viewController: UIViewController?
    
    private var state = IntentState.New
    public var currentState: IntentState { return state }
    
    public var completion: IntentCompletion?
    
    public init(selfsustaining: Bool = false, completion: IntentCompletion? = nil) {
        self.completion = completion
        if (selfsustaining) {
            becomeSelfSustaining()
        }
    }
    
    // MARK: Completion
    private final func completeWithState(state: IntentState) {
        self.state = state
        completion?(intent: self, state: currentState)
        if isSelfSustaining {
            resignSelfSustainingState()
        }
    }
    
    private final func showAlertWithTitle(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let buttonTitle = localizedString("ffuikit_btn_ok", comment: "FFUIKit.Intent")
        controller.addAction(UIAlertAction(title: buttonTitle, style: .Cancel, handler: nil))
        var vc = viewController
        if vc == nil {
            vc = findForemostViewController()
        }
        vc?.presentViewController(controller, animated: true, completion: nil)
    }
    
    public func succeed() {
        completeWithState(.Succeeded)
    }
    
    public func succeedWithMessage(message: String) {
        succeedWithTitle(localizedString("ffuikit_title_succeeded", comment: "FFUIKit.Intent"), message: message)
    }
    
    public func succeedWithTitle(title: String, message: String) {
        showAlertWithTitle(title, message: message)
        succeed()
    }
    
    public func fail() {
        completeWithState(.Failed)
    }
    
    public func failWithMessage(message: String) {
        failWithTitle(localizedString("ffuikit_title_failed", comment: "FFUIKit.Intent"), message: message)
    }
    
    public func failWithTitle(title: String, message: String) {
        showAlertWithTitle(title, message: message)
        fail()
    }
    
    // MARK: Run
    public func run() {
        state = .Running
        if viewController == nil {
            print("WARNING: Intent has no view controller set! Completion alerts might not work as expected!")
        }
    }
    
    public func cancel() {
        completeWithState(.Cancelled)
    }
    
    // MARK: SelfSustaining State
    public func becomeSelfSustaining() {
        if !isSelfSustaining {
            selfSustaining = true
            selfSustainingIndex = SelfSustainingIntents.count
            SelfSustainingIntents.append(self)
        }
    }
    
    public func resignSelfSustainingState() {
        if isSelfSustaining {
            selfSustaining = false
            SelfSustainingIntents.removeAtIndex(selfSustainingIndex!)
        }
    }
}
