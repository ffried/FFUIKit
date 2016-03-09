//
//  LicenseDetailViewController.swift
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

import UIKit

public class LicenseDetailViewController: UIViewController {
    
    private var _preferredStatusBarStyle: UIStatusBarStyle = .Default
    public func setPreferredStatusBarStyle(style: UIStatusBarStyle) {
        _preferredStatusBarStyle = style
    }
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return _preferredStatusBarStyle
    }
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clearColor()
        tv.editable = false
        tv.dataDetectorTypes = .Link
        tv.selectable = true
        tv.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: -10.0)
        tv.clipsToBounds = false
        return tv
        }()
    
    public var license: License! {
        didSet { if isViewLoaded() { updateContents() } }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textView.setupFullscreenInView(view, withInsets: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0))
        textView.delegate = self
        if license != nil { updateContents() }
    }
    
    deinit { textView.delegate = nil }
    
    private func updateContents() {
        title = license.title
        textView.attributedText = license.licenseContent
    }
}

extension LicenseDetailViewController: UITextViewDelegate {
    @objc public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
}
