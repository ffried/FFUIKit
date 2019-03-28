//
//  CALayer+AnimationKey.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 23.09.17.
//  Copyright © 2017 Florian Friedrich. All rights reserved.
//

import UIKit

extension CALayer {
    public struct AnimationKey: RawRepresentable {
        public typealias RawValue = String
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public init(_ rawValue: String) { self.init(rawValue: rawValue) }
    }

    public func add(_ anim: CAAnimation, for key: AnimationKey?) {
        add(anim, forKey: key?.rawValue)
    }

    public func removeAnimation(for key: AnimationKey) {
        removeAnimation(forKey: key.rawValue)
    }

    public func animationKeys() -> [AnimationKey]? {
        return animationKeys()?.map(AnimationKey.init(rawValue:))
    }

    public func animation(for key: AnimationKey) -> CAAnimation? {
        return animation(forKey: key.rawValue)
    }
}
