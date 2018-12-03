//
//  UIStoryboard+Identifier.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 03.12.18.
//  Copyright © 2018 Florian Friedrich. All rights reserved.
//

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
