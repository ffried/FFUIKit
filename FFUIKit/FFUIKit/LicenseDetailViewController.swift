//
//  LicenseDetailViewController.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 31.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFUIKit

public class LicenseDetailViewController: UIViewController {
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.setTranslatesAutoresizingMaskIntoConstraints(false)
        tv.backgroundColor = UIColor.clearColor()
        tv.editable = false
        return tv
        }()
    
    public var license: License! {
        didSet { if isViewLoaded() { updateContents() } }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView(textView, fullscreenInView: view)
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
    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
}
