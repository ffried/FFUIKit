//
//  UIApplication+Version.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 17.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFUIKit

public extension UIApplication {
    public var name: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")! as! String
    }
    
    public var version: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")! as! String
    }
    
    public var build: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion")! as! String
    }
    
    public var fullVersion: String {
        return "\(version) (\(build))"
    }
    
    public var nameAndFullVersion: String {
        return "\(name) \(fullVersion)"
    }
}
