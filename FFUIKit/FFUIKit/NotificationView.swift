//
//  NotificationView.swift
//  NotificationsController
//
//  Created by Florian Friedrich on 13/03/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
//

import UIKit

public final class TextNotificationView: UIView, NotificationViewType {
    public let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    private final func initialize() {
        addSubview(textLabel)
        let views = ["label": textLabel]
        ["H:|-5-[label]-5@999-|", "V:|-25-[label]-5@999-|"].constraintsWithViews(views).activate()
        layoutIfNeeded()
    }
}
