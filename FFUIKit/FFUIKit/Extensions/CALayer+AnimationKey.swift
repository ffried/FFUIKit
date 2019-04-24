//
//  CALayer+AnimationKey.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 23.09.17.
//  Copyright © 2017 Florian Friedrich. All rights reserved.
//

import class UIKit.CALayer
import class UIKit.CAAnimation

extension CALayer {
    public struct AnimationKey: RawRepresentable {
        public typealias RawValue = String
        public let rawValue: RawValue
        public init(rawValue: RawValue) { self.rawValue = rawValue }
        @inlinable
        public init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }
    }

    @inlinable
    public func add(_ anim: CAAnimation, for key: AnimationKey?) {
        add(anim, forKey: key?.rawValue)
    }

    @inlinable
    public func removeAnimation(for key: AnimationKey) {
        removeAnimation(forKey: key.rawValue)
    }

    @inlinable
    public func animationKeys() -> [AnimationKey]? {
        return animationKeys()?.map(AnimationKey.init(rawValue:))
    }

    @inlinable
    public func animation(for key: AnimationKey) -> CAAnimation? {
        return animation(forKey: key.rawValue)
    }
}
