//
//  UIColor+HexTests.swift
//  FFUIKit Tests
//
//  Created by Florian Friedrich on 10.04.19.
//  Copyright © 2019 Florian Friedrich. All rights reserved.
//

import XCTest
import FFUIKit

fileprivate func XCTAssertEqual(_ color: UIColor, _ values: (r: UInt8, g: UInt8, b: UInt8, a: UInt8), _ message: @autoclosure() -> String = "", file: StaticString = #file, line: UInt = #line) {
    var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
    XCTAssertTrue(color.getRed(&r, green: &g, blue: &b, alpha: &a), "Could not retrieve RGBA values. \(message())", file: file, line: line)
    XCTAssertEqual(r, CGFloat(values.r) / 255, "Red value is not equal. \(message())", file: file, line: line)
    XCTAssertEqual(g, CGFloat(values.g) / 255, "Green value is not equal. \(message())", file: file, line: line)
    XCTAssertEqual(b, CGFloat(values.b) / 255, "Blue value is not equal. \(message())", file: file, line: line)
    XCTAssertEqual(a, CGFloat(values.a) / 255, "Alpha value is not equal. \(message())", file: file, line: line)
}

final class UIColor_HexTests: XCTestCase {
    func testCreationFromValidRGBHexInteger() {
        let color = UIColor(rgbHex: 0x123456)
        XCTAssertEqual(color, (0x12, 0x34, 0x56, 0xFF))
    }

    func testCreationFromValidRGBAHexInteger() {
        let color = UIColor(rgbaHex: 0x12345678)
        XCTAssertEqual(color, (0x12, 0x34, 0x56, 0x78))
    }

    func testCreationFromInvalidRGBHexInteger() {
        let color = UIColor(rgbHex: 0x0 as UInt8)
        XCTAssertEqual(color, (0x0, 0x0, 0x0, 0xFF))
    }

    func testCreationFromInvalidRGBAHexInteger() {
        let color = UIColor(rgbaHex: 0x0 as UInt8)
        XCTAssertEqual(color, (0x0, 0x0, 0x0, 0x0))
    }

    func testCreationFromValidRGBHexString() {
        let color = UIColor(hexString: "0x123456")
        XCTAssertEqual(color, (0x12, 0x34, 0x56, 0xFF))
    }

    func testCreationFromValidRGBAHexString() {
        let color = UIColor(hexString: "0x12345678")
        XCTAssertEqual(color, (0x12, 0x34, 0x56, 0x78))
    }

    func testCreationFromHexStringsWithPrefixes() {
        let color1 = UIColor(hexString: "0x123456")
        let color2 = UIColor(hexString: "#123456")
        let color3 = UIColor(hexString: "123456")
        XCTAssertEqual(color1, (0x12, 0x34, 0x56, 0xFF))
        XCTAssertEqual(color2, (0x12, 0x34, 0x56, 0xFF))
        XCTAssertEqual(color3, (0x12, 0x34, 0x56, 0xFF))
    }
}
