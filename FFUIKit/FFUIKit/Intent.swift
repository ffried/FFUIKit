//
//  Intent.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 11.12.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

import FFUIKit

public typealias IntentCompletion = (intent: Intent, succeeded: Bool, cancelled: Bool) -> ()

private var SelfSustainingIntents = [Intent]()
public class Intent {
    private final var selfSustainingIndex: Int?
    private final var selfSustaining = false
    public final var isSelfSustaining: Bool { return selfSustaining }
    
    public var viewController: UIViewController?
    
    public var completion: IntentCompletion?
    
    public init(selfsustaining: Bool = false, completion: IntentCompletion? = nil) {
        self.completion = completion
        if (selfsustaining) {
            becomeSelfSustaining()
        }
    }
    
    // MARK: Completion
    private final func completeWithSuccess(success: Bool, cancelled: Bool) {
        completion?(intent: self, succeeded: success, cancelled: cancelled)
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
        completeWithSuccess(true, cancelled: false)
    }
    
    public func succeedWithMessage(message: String) {
        showAlertWithTitle(localizedString("ffuikit_title_succeeded", comment: "FFUIKit.Intent"), message: message)
        succeed()
    }
    
    public func fail() {
        completeWithSuccess(false, cancelled: false)
    }
    
    public func failWithMessage(message: String) {
        showAlertWithTitle(localizedString("ffuikit_title_failed", comment: "FFUIKit.Intent"), message: message)
        fail()
    }
    
    // MARK: Run
    public func run() {}
    
    public func cancel() {
        completeWithSuccess(false, cancelled: true)
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
