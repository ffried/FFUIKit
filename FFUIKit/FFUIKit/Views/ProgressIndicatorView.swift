//
//  ProgressIndicatorView.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 20.08.17.
//  Copyright © 2017 Florian Friedrich. All rights reserved.
//

import class Foundation.NSCoder
import typealias Foundation.TimeInterval
import UIKit
import enum FFFoundation.Angle

fileprivate extension CALayer.AnimationKey {
    static let rotation = CALayer.AnimationKey(rawValue: "FFProgressIndicatorAnimation")
}

@IBDesignable
public final class ProgressIndicatorView: TouchAwareControl {
    
    @IBInspectable public var gapInDegrees: CGFloat {
        get { return gap.asDegrees.value }
        set { return gap = .degrees(newValue) }
    }
    @IBInspectable public var rotationDuration: TimeInterval = 1.0
    @IBInspectable public var hidesWhenStopped: Bool = true {
        didSet { isHidden = hidesWhenStopped && !isAnimating }
    }
    @IBInspectable public var showsStopButton: Bool {
        get { return !stopButtonView.isHidden }
        set { stopButtonView.isHidden = !newValue }
    }
    
    public var gap: Angle<CGFloat> = .degrees(45)
    public private(set) var isAnimating: Bool = false
    
    private lazy var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.contentsScale = UIScreen.main.scale
        layer.strokeColor = tintColor.cgColor
        layer.lineWidth = progressBarStrokeWidth
        layer.path = bezierPath(forPercent: 0).cgPath
        return layer
    }()
    
    private lazy var stopButtonView: UIView = {
        let view = UIView()
        view.enableAutoLayout()
        view.isUserInteractionEnabled = true
        view.backgroundColor = tintColor
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stopButtonPressed(sender:))))
        return view
    }()
    
    private var progressBarStrokeWidth: CGFloat { return frame.width / 12.5 }
    private var progressBarFrame: CGRect {
        let sideLength = bounds.width - progressBarStrokeWidth * 2
        let spacing = (bounds.width - sideLength) / 2
        return CGRect(origin: CGPoint(pointValue: spacing), size: CGSize(sideLength: sideLength))
    }
    
    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        layer.addSublayer(circleLayer)
        addSubview(stopButtonView)
        
        let constraints: [NSLayoutConstraint]
        if #available(iOS 9, *) {
            constraints = [
                stopButtonView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 3.25),
                stopButtonView.centerXAnchor.constraint(equalTo: centerXAnchor),
                stopButtonView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ]
        } else {
            constraints = [
                NSLayoutConstraint(item: stopButtonView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1 / 3.25, constant: 0),
                NSLayoutConstraint(item: stopButtonView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: stopButtonView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            ]
        }
        constraints.activate()
    }
    
    // MARK: - Overrides
    public override func layoutSubviews() {
        super.layoutSubviews()
        stopButtonView.layer.cornerRadius = stopButtonView.bounds.height / 10
        if circleLayer.lineWidth != progressBarStrokeWidth {
            circleLayer.lineWidth = progressBarStrokeWidth
        }
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        if isEnabled {
            set(color: tintColor)
        }
    }
    
    // MARK: - Animations
    public func startAnimating() {
        guard !isAnimating else { return }
        defer { isAnimating = true }
        if isHidden {
            setHidden(false, animated: true)
        }
        animate()
    }

    public func stopAnimating() {
        guard isAnimating else { return }
        defer { isAnimating = false }
        if hidesWhenStopped {
            setHidden(true, animated: true, completion: { finished in
                self.circleLayer.removeAnimation(for: .rotation)
            })
        } else {
            circleLayer.removeAnimation(for: .rotation)
        }
    }
    
    private func animate() {
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.path))
        let stepCount = 1000
        animation.values = (0..<stepCount).map { bezierPath(forPercent: CGFloat($0) / CGFloat(stepCount)).cgPath }
        animation.duration = rotationDuration
        animation.repeatCount = .infinity
        circleLayer.add(animation, for: .rotation)
    }
    
    // MARK: - Hiding
    private func setHidden(_ hidden: Bool, animated: Bool = true, completion: ((Bool) -> ())? = nil) {
        guard hidden != isHidden else { completion?(true); return }
        guard animated else {
            isHidden = hidden
            completion?(true)
            return
        }
        if !hidden {
            (alpha, isHidden) = (0.0, hidden)
        }
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = hidden ? 0.0 : 1.0
        }) { finished in
            if hidden {
                self.isHidden = hidden
                self.alpha = 1.0
            }
            completion?(finished)
        }
    }
    
    // MARK: - Helpers
    private func bezierPath(forPercent percent: CGFloat) -> UIBezierPath {
        let percentAngle: Angle = .degrees(-percent) * .radians(.pi * 2) + .degrees(90)
        let (startAngle, endAngle) = (percentAngle - gap, percentAngle)
        return UIBezierPath(arcCenter: progressBarFrame.center,
                            radius: progressBarFrame.width / 2,
                            startAngle: -startAngle.asRadians.value,
                            endAngle: -endAngle.asRadians.value,
                            clockwise: true)
        
    }

    private func set(color: UIColor) {
        stopButtonView.backgroundColor = color
        circleLayer.strokeColor = color.cgColor
    }
    
    // MARK: - Actions
    @objc dynamic private func stopButtonPressed(sender: Any?) {
        guard isAnimating else { return }
        sendActions(for: .touchUpInside)
    }

    // MARK: - State
    public override var isEnabled: Bool {
        didSet { updateVisuals() }
    }

    public override var isSelected: Bool {
        didSet { updateVisuals() }
    }

    public override var isHighlighted: Bool {
        didSet { updateVisuals() }
    }

    private func updateVisuals() {
        let changes = {
            self.alpha = self.isHighlighted ? 0.2 : 1.0
            self.set(color: self.isEnabled ? self.tintColor : .lightGray)
        }
        if superview != nil && !isTrackingTouchInside {
            UIView.animate(withDuration: 0.25, delay: 0.0,
                           options: [.beginFromCurrentState, .allowAnimatedContent],
                           animations: changes, completion: nil)
        } else {
            changes()
        }
    }
}
