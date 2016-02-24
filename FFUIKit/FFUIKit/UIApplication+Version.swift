//
//  UIApplication+Version.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 17.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
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
