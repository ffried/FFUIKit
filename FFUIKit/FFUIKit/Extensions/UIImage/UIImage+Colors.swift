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

import UIKit
import ObjectiveC
import FFFoundation

fileprivate protocol Storable {}
extension Storable { mutating func stored() -> Self { return self } }

extension Set: Storable {}
extension Array: Storable {}
extension Optional: Storable {}
extension UIColor: Storable {}

private var UIImage_averageColorKey = "UIImage.averageColor"
private var UIImage_mostIntenseColorByQualityKey = "UIImage.mostIntenseColorByQuality"
private var UIImage_simpleColorsByQualityKey = "UIImage.simpleColorsByQuality"
private var UIImage_colorsByQualityKey = "UIImage.colorsByQuality"

public extension UIImage {
    private struct SimpleColor<Val: UnsignedInteger>: Hashable {
        let raw: (red: Val, green: Val, blue: Val, alpha: Val)

        let rgba: Ref<Lazy<(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)>>
        let hsba: Ref<Lazy<(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)>>

        var uiColor: UIColor {
            return UIColor(red: rgba.nestedValue.red,
                           green: rgba.nestedValue.green,
                           blue: rgba.nestedValue.blue,
                           alpha: rgba.nestedValue.alpha)
        }

        var intensity: CGFloat {
            return hsba.nestedValue.saturation + hsba.nestedValue.brightness
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(raw.red)
            hasher.combine(raw.green)
            hasher.combine(raw.blue)
            hasher.combine(raw.alpha)
        }

        init(red: Val, green: Val, blue: Val, alpha: Val) {
            raw = (red, green, blue, alpha)

            let rgbaRef = Ref(value: Lazy<(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)>({
                return (
                    red: CGFloat(red) / 255.0,
                    green: CGFloat(green) / 255.0,
                    blue: CGFloat(blue) / 255.0,
                    alpha: CGFloat(alpha) / 255.0
                )
            }))
            rgba = rgbaRef
            hsba = Ref(value: Lazy({
                let values = rgbaRef.nestedValue
                let minVal = min(values.red, values.green, values.blue)
                let maxVal = max(values.red, values.green, values.blue)
                let delta = maxVal - minVal
                let brightness = maxVal
                let saturation = delta.isZero ? 0 : delta / maxVal
                let hue: CGFloat
                switch maxVal {
                case values.red:
                    hue = (values.green - values.blue) / delta
                case values.green:
                    hue = 2 + (values.blue - values.red) / delta
                case values.blue:
                    hue = 4 + (values.red - values.green) / delta
                default:
                    fatalError("max should always be one of rgb!")
                }
                return (hue, saturation, brightness, values.alpha)
            }))
        }

        public static func ==(lhs: SimpleColor, rhs: SimpleColor) -> Bool {
            return lhs.raw == rhs.raw
        }
    }

    private final func getAssoc<T>(for key: inout String) -> T? {
        return objc_getAssociatedObject(self, &key) as? T
    }

    private final func setAssoc<T>(_ val: T?, for key: inout String, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(self, &key, val, policy)
    }

    private final func storedValue<T>(for key: inout String, generatedBy generator: () -> T, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> T {
        if let val: T = getAssoc(for: &key) { return val }
        let val = generator()
        setAssoc(val, for: &key, policy: policy)
        return val
    }

    private final func storedValue<T>(for key: inout String, generatedBy generator: () -> T?, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> T? {
        if let val: T = getAssoc(for: &key) { return val }
        let val = generator()
        setAssoc(val, for: &key, policy: policy)
        return val
    }

    public final var averageColor: UIColor? {
        func getAverageColor() -> UIColor? {
            guard let cgImage = cgImage else { return nil }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let alphaInfo: CGImageAlphaInfo = .premultipliedLast
            let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .byteOrder32Big]
            guard let context = CGContext(data: nil,
                                          width: 1, height: 1,
                                          bitsPerComponent: 8, bytesPerRow: 4,
                                          space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
                else { return nil }
            context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))

            guard let data = context.data else { return nil }
            let rgba = data.assumingMemoryBound(to: UInt8.self)

            return SimpleColor(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3]).uiColor
        }
        return storedValue(for: &UIImage_averageColorKey, generatedBy: getAverageColor)
    }

    private final var simpleColorsByQuality: Dictionary<CGFloat, Set<SimpleColor<UInt8>>> {
        get { return storedValue(for: &UIImage_simpleColorsByQualityKey, generatedBy: { [:] }) }
        set { setAssoc(newValue, for: &UIImage_simpleColorsByQualityKey) }
    }
    private final func simpleColors(quality: CGFloat) -> Set<SimpleColor<UInt8>> {
        func getSimpleColors(quality: CGFloat) -> Set<SimpleColor<UInt8>> {
            guard let cgImage = cgImage else { return [] }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let alphaInfo: CGImageAlphaInfo = .premultipliedLast
            let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue), .byteOrder32Big]
            let size = CGSize(width: cgImage.width, height: cgImage.height).applying(CGAffineTransform(scaleX: quality, y: quality))
            guard let context = CGContext(data: nil,
                                          width: .init(size.width), height: .init(size.height),
                                          bitsPerComponent: 8, bytesPerRow: 0,
                                          space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
                else { return [] }
            context.draw(cgImage, in: CGRect(origin: .zero, size: size))

            guard let data = context.data else { return [] }
            let rgba = data.assumingMemoryBound(to: UInt8.self)

            return stride(from: 0, to: context.width * context.height * 4, by: 4).reduce(into: []) {
                $0.insert(SimpleColor(red: rgba[$1/* + 0*/], green: rgba[$1 + 1], blue: rgba[$1 + 2], alpha: rgba[$1 + 3]))
            }
        }
        return simpleColorsByQuality[quality, default: getSimpleColors(quality: quality)].stored()
    }

    private final var simpleColors: Set<SimpleColor<UInt8>> {
        return simpleColors(quality: 1)
    }

    private final var colorsByQuality: Dictionary<CGFloat, [UIColor]> {
        get { return storedValue(for: &UIImage_colorsByQualityKey, generatedBy: { [:] }) }
        set { setAssoc(newValue, for: &UIImage_colorsByQualityKey) }
    }
    public final func colors(quality: CGFloat) -> [UIColor] {
        return colorsByQuality[quality, default: simpleColors(quality: quality).map { $0.uiColor }].stored()
    }

    public final var colors: [UIColor] {
        return colors(quality: 1)
    }

    private final var mostIntenseColorByQuality: Dictionary<CGFloat, UIColor?> {
        get { return storedValue(for: &UIImage_mostIntenseColorByQualityKey, generatedBy: { [:] }) }
        set { setAssoc(newValue, for: &UIImage_mostIntenseColorByQualityKey) }
    }
    public final func mostIntenseColor(quality: CGFloat) -> UIColor? {
        return mostIntenseColorByQuality[quality, default: simpleColors(quality: quality).max { $0.intensity < $1.intensity }?.uiColor].stored()
    }

    public final var mostIntenseColor: UIColor? {
        return mostIntenseColor(quality: 1)
    }

    public final func imageTinted(with color: UIColor) -> UIImage? {
        func draw(cgImage: CGImage, with rect: CGRect, in context: CGContext) {
            // translate/flip the graphics context (for transforming from CG* coords to UI* coordinates)
            context.translateBy(x: 0.0, y: -1.0)
            context.scaleBy(x: 1.0, y: -1.0)
            
            context.setBlendMode(.colorBurn)
            context.draw(cgImage, in: rect)
            context.clip(to: rect, mask: cgImage)
            context.addRect(rect)
            context.drawPath(using: .fill)
        }
        
        guard let cgImage = cgImage else { return nil }
        let rect = CGRect(origin: .zero, size: size)
        
        if #available(iOS 10, *) {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image {
                color.setFill()
                draw(cgImage: cgImage, with: rect, in: $0.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer { UIGraphicsEndImageContext() }
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            
            color.setFill()
            draw(cgImage: cgImage, with: rect, in: context)
            
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}
