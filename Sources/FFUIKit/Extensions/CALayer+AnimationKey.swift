//
//  CALayer+AnimationKey.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 23.09.17.
//  Copyright © 2017 Florian Friedrich. All rights reserved.
//

#if !os(watchOS)
import class UIKit.CALayer
import class UIKit.CAAnimation

extension CALayer {
    public struct AnimationKey: RawRepresentable, Sendable, Hashable {
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
        animationKeys()?.map(AnimationKey.init(rawValue:))
    }

    @inlinable
    public func animation(for key: AnimationKey) -> CAAnimation? {
        animation(forKey: key.rawValue)
    }
}
#endif
