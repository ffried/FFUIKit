//
//  UIApplication+AppStore.swift
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

/// FFUIKitiTunesIdentifier
public let FFUIKitiTunesIdentifierInfoDictionaryKey = "FFUIKitiTunesIdentifier"

public extension UIApplication {
    private final var iTunesBaseURL: String {
        return "https://itunes.apple.com/"
    }
    
    /// Returns the value for "FFUIKitiTunesIdentifier" in info plist
    public final var iTunesIdentifier: String? {
        #if swift(>=3.0)
            return Bundle.main.infoDictionary?[FFUIKitiTunesIdentifierInfoDictionaryKey] as? String
        #else
            return NSBundle.mainBundle().infoDictionary?[FFUIKitiTunesIdentifierInfoDictionaryKey] as? String
        #endif
    }
    
    #if swift(>=3.0)
    public final var iTunesURL: URL {
        let appID = iTunesIdentifier ?? ""
        return URL(string: "\(iTunesBaseURL)app/id\(appID)")!
    }
    
    public final var iTunesRatingURL: URL {
        let appID = iTunesIdentifier ?? ""
        let urlString = "\(iTunesBaseURL)WebObjects/MZStore.woa/wa/viewContentsUserReviews?pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8&id=\(appID)"
        return URL(string: urlString)!
    }
    #else
    public final var iTunesURL: NSURL {
        let appID = iTunesIdentifier ?? ""
        return NSURL(string: "\(iTunesBaseURL)app/id\(appID)")!
    }
    
    public final var iTunesRatingURL: NSURL {
        let appID = iTunesIdentifier ?? ""
        let urlString = "\(iTunesBaseURL)WebObjects/MZStore.woa/wa/viewContentsUserReviews?pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8&id=\(appID)"
        return NSURL(string: urlString)!
    }
    #endif
}
