//
//  License.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 31.1.15.
//  Copyright 2015 Florian Friedrich
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

import struct Foundation.URL
import class Foundation.Bundle
import class Foundation.NSAttributedString
#if canImport(os)
import func os.os_log
#else
import func FFFoundation.os_log
#endif

fileprivate extension NSAttributedString {
    convenience init?(licenseFile: URL) {
        do {
            try self.init(url: licenseFile, options: [:], documentAttributes: nil)
        } catch {
            os_log("Failed to read license content: %@", log: .ffUIKit, type: .error, String(describing: error))
            return nil
        }
    }
}

public struct License: Hashable {
    public let title: String
    public let file: URL
    public let content: Lazy<NSAttributedString?>

    public init(title: String, file: URL) {
        self.title = title
        self.file = file
        self.content = Lazy { NSAttributedString(licenseFile: file) }
    }

    public init?(title: String, fileExtension: String, in bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: title, withExtension: fileExtension) else { return nil }
        self.init(title: title, file: url)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(file)
    }

    public static func ==(lhs: License, rhs: License) -> Bool {
        return (lhs.title, lhs.file) == (rhs.title, rhs.file)
    }
}
