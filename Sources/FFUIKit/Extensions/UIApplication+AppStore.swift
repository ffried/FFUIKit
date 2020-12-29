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

#if !os(watchOS)
import struct Foundation.URL
import struct Foundation.URLComponents
import struct Foundation.URLQueryItem
import class Foundation.Bundle
import class UIKit.UIApplication

extension UIApplication {
    /// FFUIKitiTunesIdentifier
    public static let iTunesIdentifierInfoDictionaryKey: String = "FFUIKitiTunesIdentifier"

    private final var iTunesBaseURL: URL {
        URL(string: "https://itunes.apple.com")!
    }

    /// Returns the value for "FFUIKitiTunesIdentifier" in info plist
    public final var iTunesIdentifier: String? {
        Bundle.main.infoDictionary?[UIApplication.iTunesIdentifierInfoDictionaryKey] as? String
    }

    public final var iTunesURL: URL {
        let appID = iTunesIdentifier ?? ""
        return iTunesBaseURL.appendingPathComponent("app").appendingPathComponent("id\(appID)")
    }

    public final var iTunesRatingURL: URL {
        var comps = URLComponents(url: iTunesURL, resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "action", value: "write-review")]
        return comps.url!
    }
}
#endif
