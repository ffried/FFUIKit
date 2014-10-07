//
//  FFProgressIndicatorView.h
//  FFUIKit
//
//  Created by Florian Friedrich on 07.10.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

@import UIKit;

IB_DESIGNABLE
@interface FFProgressIndicatorView : UIControl

@property (nonatomic) IBInspectable CGFloat gapInDegrees;
@property (nonatomic) IBInspectable CGFloat rotationDuration;
@property (nonatomic) IBInspectable BOOL stopButtonVisible;

@property (nonatomic) IBInspectable BOOL hidesWhenStopped;

@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

- (void)startAnimating;
- (void)stopAnimating;

@end
