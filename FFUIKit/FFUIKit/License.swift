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

import Foundation

public struct License: Hashable {
    public let title: String
    public let licenseFilePath: NSURL
    
    public private(set) var licenseContent: NSAttributedString?
    
    public var hashValue: Int { return self.title.hashValue ^ self.licenseFilePath.hashValue }
    
    public init(title: String, licenseFilePath: NSURL) {
        self.title = title
        self.licenseFilePath = licenseFilePath
        self.licenseContent = readContents()
    }
    
    public init(title: String, fileExtension: String) {
        let url = NSBundle.mainBundle().URLForResource(title, withExtension: fileExtension)!
        self.init(title: title, licenseFilePath: url)
    }
    
    private mutating func readContents() -> NSAttributedString? {
        let content: NSAttributedString?
        do {
            if #available(iOS 9.0, *) {
                content = try NSAttributedString(URL: licenseFilePath, options: [:], documentAttributes: nil)
            } else {
                content = try NSAttributedString(fileURL: licenseFilePath, options: [:], documentAttributes: nil)
            }
        }
        catch {
            print("FFUIKit: Failed to read license content: \(error)")
            content = nil
        }
        return content
    }
}

public func ==(lhs: License, rhs: License) -> Bool {
    return lhs.title == rhs.title && lhs.licenseFilePath.isEqual(rhs.licenseFilePath)
}
