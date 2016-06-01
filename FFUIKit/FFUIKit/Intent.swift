//
//  Intent.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 11.12.14.
//  Copyright 2014 Florian Friedrich
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

@available(*, deprecated, message="This is very similar to what Apple provides in Advanced NSOperations. We suggest using NSOperations!")
public class Intent {
    private static var SelfSustainingIntents = [Intent]()
    
    public typealias Completion = (intent: Intent, state: State) -> ()
    
    public enum State {
        case New
        case Running
        case Succeeded
        case Failed
        case Cancelled
    }
    
    private final var selfSustainingIndex: Int?
    public private(set) final var isSelfSustaining = false
    
    public var viewController: UIViewController?
    
    public private(set) var currentState = State.New
    
    public var completion: Completion?
    
    public init(selfsustaining: Bool = false, completion: Completion? = nil) {
        self.completion = completion
        if selfsustaining {
            becomeSelfSustaining()
        }
    }
    
    // MARK: Completion
    private final func completeWithState(state: State) {
        currentState = state
        completion?(intent: self, state: currentState)
        if isSelfSustaining {
            resignSelfSustainingState()
        }
    }
    
    private final func showAlertWithTitle(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let buttonTitle = NSLocalizedString("ffuikit_btn_ok", comment: "FFUIKit.Intent")
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
        succeedWithTitle(NSLocalizedString("ffuikit_title_succeeded", comment: "FFUIKit.Intent"), message: message)
    }
    
    public func succeedWithTitle(title: String, message: String) {
        showAlertWithTitle(title, message: message)
        succeed()
    }
    
    public func fail() {
        completeWithState(.Failed)
    }
    
    public func failWithMessage(message: String) {
        failWithTitle(NSLocalizedString("ffuikit_title_failed", comment: "FFUIKit.Intent"), message: message)
    }
    
    public func failWithTitle(title: String, message: String) {
        showAlertWithTitle(title, message: message)
        fail()
    }
    
    // MARK: Run
    public func run() {
        currentState = .Running
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
            isSelfSustaining = true
            selfSustainingIndex = self.dynamicType.SelfSustainingIntents.count
            self.dynamicType.SelfSustainingIntents.append(self)
        }
    }
    
    public func resignSelfSustainingState() {
        if isSelfSustaining {
            isSelfSustaining = false
            self.dynamicType.SelfSustainingIntents.removeAtIndex(selfSustainingIndex!)
        }
    }
}
