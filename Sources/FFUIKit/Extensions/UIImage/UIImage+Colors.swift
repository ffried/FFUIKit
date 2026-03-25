//
//  UIImage+Colors.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 24/02/16.
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

import ObjectiveC
public import UIKit
import FFFoundation
import ColorComponents

fileprivate extension Dictionary {
    subscript(key: Key, orStored defaultProvider: @autoclosure () -> Value) -> Value {
        mutating get {
            if let existing = self[key] { return existing }
            let new = defaultProvider()
            self[key] = new
            return new
        }
        set {
            self[key] = newValue
        }
    }
}

nonisolated(unsafe) fileprivate var UIImage_averageColorKey: StaticString = "UIImage.averageColor"
nonisolated(unsafe) fileprivate var UIImage_mostIntenseColorByQualityKey: StaticString = "UIImage.mostIntenseColorByQuality"
nonisolated(unsafe) fileprivate var UIImage_simpleColorsByQualityKey: StaticString = "UIImage.simpleColorsByQuality"
nonisolated(unsafe) fileprivate var UIImage_colorsByQualityKey: StaticString = "UIImage.colorsByQuality"

fileprivate extension HSB where Value: AdditiveArithmetic {
    var intensity: Value { saturation + brightness }
}

fileprivate extension HSBA where Value: AdditiveArithmetic {
    var intensity: Value { hsb.intensity }
}

extension UIImage {
    private struct SimpleColor: Hashable {
        let rgba: RGBA<UInt8>

        @Lazy private(set) var uiColor: UIColor
        @Lazy private(set) var intensity: CGFloat

        init(rgba: RGBA<UInt8>) {
            self.rgba = rgba

            let cgRGBA = Lazy<RGBA<CGFloat>> { RGBA<CGFloat>(rgba) }
            _uiColor = Lazy { UIColor(cgRGBA.wrappedValue) }
            _intensity = Lazy { HSBA(rgba: cgRGBA.wrappedValue).intensity }
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(rgba)
        }

        static func ==(lhs: SimpleColor, rhs: SimpleColor) -> Bool {
            lhs.rgba == rhs.rgba
        }
    }

#if compiler(>=6.3)
    @inline(always)
    private final func getAssoc<T>(for key: inout StaticString) -> T? {
        unsafe objc_getAssociatedObject(self, &key) as? T
    }
#else
    @inline(__always)
    private final func getAssoc<T>(for key: inout StaticString) -> T? {
#if compiler(>=6.2)
        unsafe objc_getAssociatedObject(self, &key) as? T
#else
        objc_getAssociatedObject(self, &key) as? T
#endif
    }
#endif

#if compiler(>=6.3)
    @inline(always)
    private final func setAssoc<T>(_ val: T?, for key: inout StaticString, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        unsafe objc_setAssociatedObject(self, &key, val, policy)
    }
#else
    @inline(__always)
    private final func setAssoc<T>(_ val: T?, for key: inout StaticString, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
#if compiler(>=6.2)
        unsafe objc_setAssociatedObject(self, &key, val, policy)
#else
        objc_setAssociatedObject(self, &key, val, policy)
#endif
    }
#endif

#if compiler(>=6.3)
    @inline(always)
    private final func storedValue<T>(for key: inout StaticString, generatedBy generator: () -> T, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> T {
        if let val: T = getAssoc(for: &key) { return val }
        let val = generator()
        setAssoc(val, for: &key, policy: policy)
        return val
    }

    @inline(always)
    private final func storedValue<T>(for key: inout StaticString, generatedBy generator: () -> T?, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> T? {
        if let val: T = getAssoc(for: &key) { return val }
        let val = generator()
        setAssoc(val, for: &key, policy: policy)
        return val
    }
#else
    @inline(__always)
    private final func storedValue<T>(for key: inout StaticString, generatedBy generator: () -> T, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> T {
        if let val: T = getAssoc(for: &key) { return val }
        let val = generator()
        setAssoc(val, for: &key, policy: policy)
        return val
    }

    @inline(__always)
    private final func storedValue<T>(for key: inout StaticString, generatedBy generator: () -> T?, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> T? {
        if let val: T = getAssoc(for: &key) { return val }
        let val = generator()
        setAssoc(val, for: &key, policy: policy)
        return val
    }
#endif

    public final var averageColor: UIColor? {
        func getAverageColor() -> UIColor? {
            guard let cgImage = cgImage else { return nil }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let alphaInfo: CGImageAlphaInfo = .premultipliedLast
            let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .byteOrder32Big]
#if compiler(>=6.2)
            guard let context = unsafe CGContext(data: nil,
                                                 width: 1, height: 1,
                                                 bitsPerComponent: 8, bytesPerRow: 4,
                                                 space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            else { return nil }
#else
            guard let context = CGContext(data: nil,
                                          width: 1, height: 1,
                                          bitsPerComponent: 8, bytesPerRow: 4,
                                          space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            else { return nil }
#endif
            context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
#if compiler(>=6.2)
            guard let data = unsafe context.data else { return nil }
            let rgba = unsafe data.assumingMemoryBound(to: UInt8.self)
            return unsafe .init(RGBA(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3]))
#else
            guard let data = context.data else { return nil }
            let rgba = data.assumingMemoryBound(to: UInt8.self)
            return .init(RGBA(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3]))
#endif
        }
#if compiler(>=6.2)
        return unsafe storedValue(for: &UIImage_averageColorKey, generatedBy: getAverageColor)
#else
        return storedValue(for: &UIImage_averageColorKey, generatedBy: getAverageColor)
#endif
    }
#if compiler(>=6.2)
    private final var simpleColorsByQuality: Dictionary<CGFloat, Set<SimpleColor>> {
        get { unsafe storedValue(for: &UIImage_simpleColorsByQualityKey, generatedBy: { [:] }) }
        set { unsafe setAssoc(newValue, for: &UIImage_simpleColorsByQualityKey) }
    }
#else
    private final var simpleColorsByQuality: Dictionary<CGFloat, Set<SimpleColor>> {
        get { storedValue(for: &UIImage_simpleColorsByQualityKey, generatedBy: { [:] }) }
        set { setAssoc(newValue, for: &UIImage_simpleColorsByQualityKey) }
    }
#endif
    private final func simpleColors(quality: CGFloat) -> Set<SimpleColor> {
        func getSimpleColors(quality: CGFloat) -> Set<SimpleColor> {
            guard let cgImage = cgImage else { return [] }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let alphaInfo: CGImageAlphaInfo = .premultipliedLast
            let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .byteOrder32Big]
            let size = CGSize(width: cgImage.width, height: cgImage.height).applying(CGAffineTransform(scaleX: quality, y: quality))
#if compiler(>=6.2)
            guard let context = unsafe CGContext(data: nil,
                                                 width: .init(size.width), height: .init(size.height),
                                                 bitsPerComponent: 8, bytesPerRow: 0,
                                                 space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            else { return [] }
#else
            guard let context = CGContext(data: nil,
                                          width: .init(size.width), height: .init(size.height),
                                          bitsPerComponent: 8, bytesPerRow: 0,
                                          space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            else { return [] }
#endif
            context.draw(cgImage, in: CGRect(origin: .zero, size: size))

#if compiler(>=6.2)
            guard let data = unsafe context.data else { return [] }
            let rgba = unsafe data.assumingMemoryBound(to: UInt8.self)
            let rawValues = Set(stride(from: 0, to: context.width * context.height * 4, by: 4).map {
                unsafe RGBA(red: rgba[$0/* + 0*/], green: rgba[$0 + 1], blue: rgba[$0 + 2], alpha: rgba[$0 + 3])
            })
#else
            guard let data = context.data else { return [] }
            let rgba = data.assumingMemoryBound(to: UInt8.self)
            let rawValues = Set(stride(from: 0, to: context.width * context.height * 4, by: 4).map {
                RGBA(red: rgba[$0/* + 0*/], green: rgba[$0 + 1], blue: rgba[$0 + 2], alpha: rgba[$0 + 3])
            })
#endif
            return Set(rawValues.map(SimpleColor.init))
        }
        return simpleColorsByQuality[quality, orStored: getSimpleColors(quality: quality)]
    }

    private final var simpleColors: Set<SimpleColor> {
        simpleColors(quality: 1)
    }

#if compiler(>=6.2)
    private final var colorsByQuality: Dictionary<CGFloat, [UIColor]> {
        get { unsafe storedValue(for: &UIImage_colorsByQualityKey, generatedBy: { [:] }) }
        set { unsafe setAssoc(newValue, for: &UIImage_colorsByQualityKey) }
    }
#else
    private final var colorsByQuality: Dictionary<CGFloat, [UIColor]> {
        get { storedValue(for: &UIImage_colorsByQualityKey, generatedBy: { [:] }) }
        set { setAssoc(newValue, for: &UIImage_colorsByQualityKey) }
    }
#endif
    public final func colors(quality: CGFloat) -> [UIColor] {
        colorsByQuality[quality, orStored: simpleColors(quality: quality).map { $0.uiColor }]
    }

    public final var colors: [UIColor] {
        colors(quality: 1)
    }

#if compiler(>=6.2)
    private final var mostIntenseColorByQuality: Dictionary<CGFloat, UIColor?> {
        get { unsafe storedValue(for: &UIImage_mostIntenseColorByQualityKey, generatedBy: { [:] }) }
        set { unsafe setAssoc(newValue, for: &UIImage_mostIntenseColorByQualityKey) }
    }
#else
    private final var mostIntenseColorByQuality: Dictionary<CGFloat, UIColor?> {
        get { storedValue(for: &UIImage_mostIntenseColorByQualityKey, generatedBy: { [:] }) }
        set { setAssoc(newValue, for: &UIImage_mostIntenseColorByQualityKey) }
    }
#endif
    public final func mostIntenseColor(quality: CGFloat) -> UIColor? {
        mostIntenseColorByQuality[quality, orStored: simpleColors(quality: quality).max { $0.intensity < $1.intensity }?.uiColor]
    }

    public final var mostIntenseColor: UIColor? {
        mostIntenseColor(quality: 1)
    }

    public final func imageTinted(with color: UIColor) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        let rect = CGRect(origin: .zero, size: size)

        func draw(in context: CGContext) {
            color.setFill()

            // translate/flip the graphics context (for transforming from CG* coords to UI* coordinates)
            context.translateBy(x: 0, y: -1)
            context.scaleBy(x: 1, y: -1)

            context.setBlendMode(.colorBurn)
            context.draw(cgImage, in: rect)
            context.clip(to: rect, mask: cgImage)
            context.addRect(rect)
            context.drawPath(using: .fill)
        }

#if os(watchOS)
        func _legacyDrawing() -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer { UIGraphicsEndImageContext() }
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            draw(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return _legacyDrawing()
#else
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { draw(in: $0.cgContext) }
#endif
    }
}
