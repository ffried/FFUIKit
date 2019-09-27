//
//  UIDevice+Hardware.swift
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

import class UIKit.UIDevice
import func Darwin.sysctlbyname

fileprivate extension UIDevice {
    static let platformNameMapping = [
        "iPhone1,1"        : "iPhone 1G",
        "iPhone1,2"        : "iPhone 3G",
        "iPhone2,1"        : "iPhone 3GS",
        "iPhone3,1"        : "iPhone 4",
        "iPhone3,3"        : "iPhone 4 Verizon",
        "iPhone4,1"        : "iPhone 4S",
        "iPhone5,1"        : "iPhone 5 (GSM)",
        "iPhone5,2"        : "iPhone 5 (GSM+CDMA)",
        "iPhone5,3"        : "iPhone 5c (GSM)",
        "iPhone5,4"        : "iPhone 5c (GSM+CDMA)",
        "iPhone6,1"        : "iPhone 5s (GSM)",
        "iPhone6,2"        : "iPhone 5s (GSM+CDMA)",
        "iPhone7,1"        : "iPhone 6 Plus",
        "iPhone7,2"        : "iPhone 6",
        "iPhone8,1"        : "iPhone 6s",
        "iPhone8,2"        : "iPhone 6s Plus",
        "iPhone8,4"        : "iPhone SE",
        "iPhone9,1"        : "iPhone 7",
        "iPhone9,2"        : "iPhone 7 Plus",
        "iPhone9,3"        : "iPhone 7",
        "iPhone9,4"        : "iPhone 7 Plus",
        "iPhone10,1"       : "iPhone 8",
        "iPhone10,2"       : "iPhone 8 Plus",
        "iPhone10,3"       : "iPhone X",
        "iPhone10,4"       : "iPhone 8",
        "iPhone10,5"       : "iPhone 8 Plus",
        "iPhone10,6"       : "iPhone X (GSM)",
        "iPhone11,2"       : "iPhone XS",
        "iPhone11,4"       : "iPhone XS Max (China)",
        "iPhone11,6"       : "iPhone XS Max",
        "iPhone11,8"       : "iPhone XR",
        "iPhone12,1"       : "iPhone 11",
        "iPhone12,3"       : "iPhone 11 Pro",
        "iPhone12,5"       : "iPhone 11 Pro Max",
        
        "Watch1,1"         : "Apple Watch 38mm",
        "Watch1,2"         : "Apple Watch 42mm",
        "Watch2,6"         : "Apple Watch Series 1 38mm",
        "Watch2,7"         : "Apple Watch Series 1 42mm",
        "Watch2,3"         : "Apple Watch Series 2 38mm",
        "Watch2,4"         : "Apple Watch Series 2 42mm",
        "Watch3,1"         : "Apple Watch Series 3 38mm (Cellular)",
        "Watch3,2"         : "Apple Watch Series 3 42mm (Cellular)",
        "Watch3,3"         : "Apple Watch Series 3 38mm",
        "Watch3,4"         : "Apple Watch Series 3 42mm",
        "Watch4,1"         : "Apple Watch Series 4 40mm",
        "Watch4,2"         : "Apple Watch Series 4 44mm",
        "Watch4,3"         : "Apple Watch Series 4 40mm (Cellular)",
        "Watch4,4"         : "Apple Watch Series 4 44mm (Cellular)",
        "Watch5,1"         : "Apple Watch Series 5 40mm",
        "Watch5,2"         : "Apple Watch Series 5 44mm",
        "Watch5,3"         : "Apple Watch Series 5 40mm (Cellular)",
        "Watch5,4"         : "Apple Watch Series 5 44mm (Cellular)",
        
        "iPod1,1"          : "iPod Touch 1G",
        "iPod2,1"          : "iPod Touch 2G",
        "iPod3,1"          : "iPod Touch 3G",
        "iPod4,1"          : "iPod Touch 4G",
        "iPod5,1"          : "iPod Touch 5G",
        "iPod7,1"          : "iPod Touch 6G",
        "iPod9,1"          : "iPod Touch 7G",
        
        "iPad1,1"          : "iPad",
        "iPad2,1"          : "iPad 2 (WiFi)",
        "iPad2,2"          : "iPad 2 (GSM)",
        "iPad2,3"          : "iPad 2 (CDMA)",
        "iPad2,4"          : "iPad 2 (WiFi)",
        "iPad2,5"          : "iPad Mini (WiFi)",
        "iPad2,6"          : "iPad Mini (GSM)",
        "iPad2,7"          : "iPad Mini (GSM+CDMA)",
        "iPad3,1"          : "iPad 3 (WiFi)",
        "iPad3,2"          : "iPad 3 (GSM+CDMA)",
        "iPad3,3"          : "iPad 3 (GSM)",
        "iPad3,4"          : "iPad 4 (WiFi)",
        "iPad3,5"          : "iPad 4 (GSM)",
        "iPad3,6"          : "iPad 4 (GSM+CDMA)",
        "iPad4,1"          : "iPad Air (WiFi)",
        "iPad4,2"          : "iPad Air (Cellular)",
        "iPad4,3"          : "iPad Air",
        "iPad4,4"          : "iPad mini 2G (WiFi)",
        "iPad4,5"          : "iPad mini 2G (Cellular)",
        "iPad4,7"          : "iPad mini 3 (WiFi)",
        "iPad4,8"          : "iPad mini 3 (Cellular)",
        "iPad4,9"          : "iPad mini 3 (China Model)",
        "iPad5,1"          : "iPad mini 4 (WiFi)",
        "iPad5,2"          : "iPad mini 4 (Cellular)",
        "iPad5,3"          : "iPad Air 2 (WiFi)",
        "iPad5,4"          : "iPad Air 2 (Cellular)",
        "iPad6,3"          : "iPad Pro (9.7\") (WiFi)",
        "iPad6,4"          : "iPad Pro (9.7\") (Cellular)",
        "iPad6,7"          : "iPad Pro (12.9\") (WiFi)",
        "iPad6,8"          : "iPad Pro (12.9\") (Cellular)",
        "iPad6,11"         : "iPad (9.7\" 5th Gen) (WiFi)",
        "iPad6,12"         : "iPad (9.7\" 5th Gen) (Cellular)",
        "iPad7,1"          : "iPad Pro 2nd Gen (12.9\") (WiFi)",
        "iPad7,2"          : "iPad Pro 2nd Gen (12.9\") (Cellular)",
        "iPad7,3"          : "iPad Pro (10.5\") (WiFi)",
        "iPad7,4"          : "iPad Pro (10.5\") (Cellular)",
        "iPad7,5"          : "iPad (9.7\" 6th Gen) (WiFi)",
        "iPad7,6"          : "iPad (9.7\" 6th Gen) (Cellular)",
        "iPad8,1"          : "iPad Pro (11\") (WiFi)",
        "iPad8,2"          : "iPad Pro (11\") (WiFi)",
        "iPad8,3"          : "iPad Pro (11\") (Cellular)",
        "iPad8,4"          : "iPad Pro (11\") (Cellular)",
        "iPad8,5"          : "iPad Pro 3rd Gen (12.9\") (WiFi)",
        "iPad8,6"          : "iPad Pro 3rd Gen (12.9\") (WiFi)",
        "iPad8,7"          : "iPad Pro 3rd Gen (12.9\") (Cellular)",
        "iPad8,8"          : "iPad Pro 3rd Gen (12.9\") (Cellular)",
        "iPad11,1"         : "iPad mini 5 (WiFi)",
        "iPad11,2"         : "iPad mini 5 (Cellular)",
        "iPad11,3"         : "iPad Air 3rd Gen (WiFi)",
        "iPad11,4"         : "iPad Air 3rd Gen (Cellular)",
        
        "AppleTV2,1"       : "Apple TV 2G",
        "AppleTV3,1"       : "Apple TV 3G",
        "AppleTV3,2"       : "Apple TV 3G",
        "AppleTV5,3"       : "Apple TV 4G",
        "AppleTV6,2"       : "Apple TV 4K",
        
        "i386"             : "Simulator",
        "x86_64"           : "Simulator",

        "AirPods1,1"       : "AirPods (1st Gen)",
        "AirPods2,1"       : "AirPods (2nd Gen)",

        "AudioAccessory1,1": "HomePod",
        "AudioAccessory1,2": "HomePod",
    ]
}

extension UIDevice {
    public final var platform: String {
        var size = Int()
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        let machine = UnsafeMutablePointer<CChar>.allocate(capacity: size)
        defer { machine.deallocate() }
        sysctlbyname("hw.machine", machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    public final var platformName: String? {
        return UIDevice.platformNameMapping[platform]
    }
}
