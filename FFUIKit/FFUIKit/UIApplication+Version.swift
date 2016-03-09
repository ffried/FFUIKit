//
//  UIApplication+Version.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 17.1.15.
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

import UIKit

public extension UIApplication {
    public var name: String? {
        return NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String
    }
    
    public var localizedName: String? {
        return NSBundle.mainBundle().localizedInfoDictionary?["CFBundleDisplayName"] as? String
    }
    
    public var version: String? {
        return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public var build: String? {
        return NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
    }
    
    public var fullVersion: String? {
        guard let version = version, build = build else { return nil }
        return "\(version) (\(build))"
    }
    
    public var nameAndFullVersion: String? {
        guard let name = name else { return nil }
        let version = fullVersion ?? ""
        return "\(name) \(version)"
    }
}
