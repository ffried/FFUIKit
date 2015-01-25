//
//  FFButton.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 25.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFUIKit

public class FFButton: UIButton {
    private var backgroundColorForStates = [UInt: UIColor]()
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        addObserver(self, forKeyPath: "state", options: nil, context: nil)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObserver(self, forKeyPath: "state", options: nil, context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "state")
    }
    
    public func setBackgroundColor(color: UIColor?, forState state: UIControlState) { // default is nil
        backgroundColorForStates[state.rawValue] = color
    }
    
    public func backgroundColorForState(state: UIControlState) -> UIColor? {
        var color: UIColor? = backgroundColorForStates[state.rawValue]
        if color == nil {
            color = backgroundColorForStates[UIControlState.Normal.rawValue]
        }
        return color
    }
    
    public var currentBackgroundColor: UIColor? { // normal/highlighted/selected/disabled. can return nil
        return backgroundColorForState(state)
    }
    
    private func didChangeState() {
        backgroundColor = currentBackgroundColor
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if object as? FFButton != self || keyPath != "state" {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        } else {
            didChangeState()
        }
    }
}
