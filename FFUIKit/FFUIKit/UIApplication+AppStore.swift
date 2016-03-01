//
//  UIApplication+AppStore.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 17.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import UIKit

// = FFUIKitiTunesIdentifier
public let FFUIKitiTunesIdentifierInfoDictionaryKey = "FFUIKitiTunesIdentifier"

public extension UIApplication {
    private final var iTunesBaseURL: String {
        return "https://itunes.apple.com/"
    }
    
    /// Returns the value for "FFUIKitiTunesIdentifier" in info plist
    public final var iTunesIdentifier: String? {
        return NSBundle.mainBundle().infoDictionary?[FFUIKitiTunesIdentifierInfoDictionaryKey] as? String
    }
    
    public final var iTunesURL: NSURL {
        let appID = iTunesIdentifier ?? ""
        return NSURL(string: "\(iTunesBaseURL)app/id\(appID)")!
    }
    
    public final var iTunesRatingURL: NSURL {
        let appID = iTunesIdentifier ?? ""
        let urlString = "\(iTunesBaseURL)WebObjects/MZStore.woa/wa/viewContentsUserReviews?pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8&id=\(appID)"
        return NSURL(string: urlString)!
    }
}
