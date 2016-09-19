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

#if swift(>=3)
@available(*, deprecated, message: "This is very similar to what Apple provides in Advanced NSOperations. We suggest using NSOperations!")
public extension Intent {}
#else
@available(*, deprecated, message="This is very similar to what Apple provides in Advanced NSOperations. We suggest using NSOperations!")
public extension Intent {}
#endif

public class Intent {
    private static var SelfSustainingIntents = [Intent]()
    
    #if swift(>=3.0)
    public typealias Completion = (Intent, State) -> ()
    #else
    public typealias Completion = (intent: Intent, state: State) -> ()
    #endif
    
    public enum State {
        #if swift(>=3)
        case new
        case running
        case succeeded
        case failed
        case cancelled
        #else
        case New
        case Running
        case Succeeded
        case Failed
        case Cancelled
        #endif
    }
    
    private final var selfSustainingIndex: Int?
    public private(set) final var isSelfSustaining = false
    
    public var viewController: UIViewController?
    
    #if swift(>=3)
    public private(set) var currentState = State.new
    #else
    public private(set) var currentState = State.New
    #endif
    
    public var completion: Completion?
    
    public required init(selfsustaining: Bool = false, completion: Completion? = nil) {
        self.completion = completion
        if selfsustaining {
            becomeSelfSustaining()
        }
    }
    
    // MARK: Completion
    #if swift(>=3)
    private final func complete(with state: State) {
        currentState = state
        completion?(self, currentState)
        if isSelfSustaining {
            resignSelfSustainingState()
        }
    }
    #else
    private final func completeWithState(state: State) {
        currentState = state
        completion?(intent: self, state: currentState)
        if isSelfSustaining {
            resignSelfSustainingState()
        }
    }
    #endif
    
    #if swift(>=3)
    private final func showAlert(with title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let buttonTitle = NSLocalizedString("ffuikit_btn_ok", comment: "FFUIKit.Intent")
        controller.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
        let vc = viewController
//        if vc == nil {
//            vc = findForemostViewController()
//        }
        vc?.present(controller, animated: true, completion: nil)
    }
    #else
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
    #endif
    
    public func succeed() {
        #if swift(>=3)
            complete(with: .succeeded)
        #else
            completeWithState(.Succeeded)
        #endif
    }
    
    #if swift(>=3)
    public func succeed(with title: String = NSLocalizedString("ffuikit_title_succeeded", comment: "FFUIKit.Intent"), message: String) {
        showAlert(with: title, message: message)
        succeed()
    }
    #else
    public func succeedWithMessage(message: String) {
        succeedWithTitle(NSLocalizedString("ffuikit_title_succeeded", comment: "FFUIKit.Intent"), message: message)
    }
    
    public func succeedWithTitle(title: String, message: String) {
        showAlertWithTitle(title, message: message)
        succeed()
    }
    #endif
    
    public func fail() {
        #if swift(>=3)
            complete(with: .failed)
        #else
            completeWithState(.Failed)
        #endif
    }
    
    #if swift(>=3)
    public func fail(with title: String = NSLocalizedString("ffuikit_title_failed", comment: "FFUIKit.Intent"), message: String) {
        showAlert(with: title, message: message)
        fail()
    }
    #else
    public func failWithMessage(message: String) {
        failWithTitle(NSLocalizedString("ffuikit_title_failed", comment: "FFUIKit.Intent"), message: message)
    }
    
    public func failWithTitle(title: String, message: String) {
        showAlertWithTitle(title, message: message)
        fail()
    }
    #endif
    
    // MARK: Run
    public func run() {
        #if swift(>=3)
            currentState = .running
        #else
            currentState = .Running
        #endif
        if viewController == nil {
            print("WARNING: Intent has no view controller set! Completion alerts might not work as expected!")
        }
    }
    
    public func cancel() {
        #if swift(>=3)
            complete(with: .cancelled)
        #else
            completeWithState(.Cancelled)
        #endif
    }
    
    // MARK: SelfSustaining State
    public final func becomeSelfSustaining() {
        if !isSelfSustaining {
            isSelfSustaining = true
            #if swift(>=3.0)
                selfSustainingIndex = type(of: self).SelfSustainingIntents.count
                type(of: self).SelfSustainingIntents.append(self)
            #else
                selfSustainingIndex = self.dynamicType.SelfSustainingIntents.count
                self.dynamicType.SelfSustainingIntents.append(self)
            #endif
        }
    }
    
    public final func resignSelfSustainingState() {
        if isSelfSustaining {
            isSelfSustaining = false
            #if swift(>=3)
                type(of: self).SelfSustainingIntents.remove(at: selfSustainingIndex!)
            #else
                self.dynamicType.SelfSustainingIntents.removeAtIndex(selfSustainingIndex!)
            #endif
        }
    }
}
