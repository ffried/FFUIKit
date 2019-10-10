//
//  UIStoryboard+Identifier.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 03.12.18.
//  Copyright © 2018 Florian Friedrich. All rights reserved.
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
import UIKit

extension UIStoryboard {
    public struct Identifier<ViewController: UIViewController>: RawRepresentable, Hashable, Codable {
        public typealias RawValue = String

        public let rawValue: RawValue
        public init(rawValue: RawValue) { self.rawValue = rawValue }
    }

    @inlinable
    public final func instantiateViewController<ViewController>(with identifier: Identifier<ViewController>) -> ViewController {
        guard let vc = instantiateViewController(withIdentifier: identifier.rawValue) as? ViewController else {
            fatalError("View controller with identifier '\(identifier.rawValue)' is not of type \(ViewController.self)!")
        }
        return vc
    }
}
#endif
