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

import struct Foundation.NSRange
import struct Foundation.URL
import protocol UIKit.UITextViewDelegate
import enum UIKit.UIStatusBarStyle
import struct UIKit.UIEdgeInsets
import class UIKit.UIColor
import class UIKit.UIView
import class UIKit.UITextView

public final class LicenseDetailViewController: UIViewController, UITextViewDelegate {

    private var _preferredStatusBarStyle: UIStatusBarStyle = .default
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return _preferredStatusBarStyle }
        set { _preferredStatusBarStyle = newValue }
    }

    private let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.dataDetectorTypes = .link
        tv.isSelectable = true
        tv.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: -10.0)
        tv.clipsToBounds = false
        return tv
    }()

    public var license: License! {
        didSet {
            if isViewLoaded { updateContents() }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textView.setupFullscreen(in: view, with: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0))
        textView.delegate = self
        if license != nil { updateContents() }
    }

    deinit {
        textView.delegate = nil
    }

    private func updateContents() {
        title = license.title
        textView.attributedText = license.content
    }

    @objc(textView:shouldInteractWithURL:inRange:)
    public dynamic func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
}
