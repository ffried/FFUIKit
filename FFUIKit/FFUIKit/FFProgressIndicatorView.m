//
//  FFProgressIndicatorView.m
//  FFUIKit
//
//  Created by Florian Friedrich on 07.10.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "FFProgressIndicatorView.h"
@import QuartzCore;

static NSString *const FFProgressIndicatorAnimationKey = @"FFProgressIndicatorAnimation";
static NSUInteger const FFProgressIndicatorAnimationSteps = 1000;

@interface FFProgressIndicatorView ()
//@property (nonatomic) CGFloat percent; // 0 - 100
@property (nonatomic, readonly) CGFloat progressBarStrokeWidth;
@property (nonatomic, readonly) CGRect progressBarFrame;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAAnimation *animation;
@property (nonatomic, strong) UIView *stopButtonView;
@end

@implementation FFProgressIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self ) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.gapInDegrees = 45.0f;
    self.rotationDuration = 1.0f;
    self.stopButtonVisible = YES;
    self.hidesWhenStopped = YES;
    
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.strokeColor = self.tintColor.CGColor;
    self.circleLayer.lineWidth = self.progressBarStrokeWidth;
    self.circleLayer.path = [self bezierPathForPercent:0.0f].CGPath;
    self.circleLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.circleLayer];
    
    [self setupStopButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.stopButtonView.layer.cornerRadius = self.stopButtonView.bounds.size.height / 10.0f;
    if (self.circleLayer.lineWidth != self.progressBarStrokeWidth) {
        self.circleLayer.lineWidth = self.progressBarStrokeWidth;
    }
}

#pragma mark - View setup
- (void)setupStopButton {
    self.stopButtonView = [[UIView alloc] init];
    self.stopButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stopButtonView.userInteractionEnabled = YES;
    self.stopButtonView.backgroundColor = self.tintColor;
    [self addSubview:self.stopButtonView];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.stopButtonView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:(1.0f / 3.25f)
                                                                   constant:0.0f];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.stopButtonView
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1.0f
                                               constant:0.0f];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.stopButtonView
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0f
                                               constant:0.0f];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.stopButtonView
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.stopButtonView
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1.0f
                                               constant:0.0f];
    [self.stopButtonView addConstraint:constraint];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(stopButtonPressed:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.stopButtonView addGestureRecognizer:tapRecognizer];
}

- (UIBezierPath *)bezierPathForPercent:(CGFloat)percent {
    CGFloat percentAngle = -percent * 360.0f + 90.0f;
    CGFloat startAngle = percentAngle - self.gapInDegrees;
    CGFloat endAngle = percentAngle;
    CGPoint center = CGPointMake(CGRectGetMidX(self.progressBarFrame), CGRectGetMidY(self.progressBarFrame));
    CGFloat radius = CGRectGetWidth(self.progressBarFrame) / 2.0f;
    return [UIBezierPath bezierPathWithArcCenter:center
                                          radius:radius
                                      startAngle:(-startAngle * M_PI / 180.0f)
                                        endAngle:(-endAngle * M_PI / 180.0f)
                                       clockwise:YES];
}

#pragma mark - Properties
- (CGFloat)progressBarStrokeWidth {
    return self.frame.size.width / 12.5f;
}

- (CGRect)progressBarFrame {
    CGFloat progressBarSideLength = self.bounds.size.width - (self.progressBarStrokeWidth * 2.0f);
    CGFloat progressBarSpacing = (self.bounds.size.width - progressBarSideLength) / 2.0f;
    return CGRectMake(progressBarSpacing, progressBarSpacing, progressBarSideLength, progressBarSideLength);
}

//- (void)setPercent:(CGFloat)percent {
//    NSAssert((percent <= 100.0f && percent >= 0.0f), @"Percent must be between 0.0f and 100.0f");
//    if (_percent != percent) {
//        _percent = percent;
//    }
//}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    if (_hidesWhenStopped != hidesWhenStopped) {
        _hidesWhenStopped = hidesWhenStopped;
        self.hidden = (_hidesWhenStopped && !self.isAnimating);
    }
}

- (BOOL)stopButtonVisible {
    return self.stopButtonView.hidden;
}

- (void)setStopButtonVisible:(BOOL)stopButtonVisible {
    self.stopButtonView.hidden = stopButtonVisible;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.stopButtonView.backgroundColor = self.tintColor;
    self.circleLayer.strokeColor = self.tintColor.CGColor;
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    [self setHidden:hidden animated:animated completion:nil];
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (!animated) {
        self.hidden = hidden;
        if (completion) completion(YES);
        return;
    }
    if (!hidden) {
        self.alpha = 0.0f;
        self.hidden = hidden;
    }
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = (hidden) ? 0.0f : 1.0f;
    } completion:^(BOOL finished) {
        if (hidden) {
            self.hidden = hidden;
            self.alpha = 1.0f;
        }
        if (completion) completion(finished);
    }];
}

#pragma mark - Animations
- (void)startAnimating {
    _animating = YES;
    if (self.hidden) {
        [self setHidden:NO animated:YES];
    }
    [self animate];
}

- (void)stopAnimating {
    _animating = NO;
    if (self.hidesWhenStopped) {
        CALayer *circleLayer = self.circleLayer;
        [self setHidden:YES animated:YES completion:^(BOOL finished) {
            [circleLayer removeAnimationForKey:FFProgressIndicatorAnimationKey];
        }];
    }
}

- (void)animate {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    NSUInteger valueCount = FFProgressIndicatorAnimationSteps;
    NSMutableArray *valuesArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < valueCount; i++) {
        [valuesArray addObject:(id)[self bezierPathForPercent:(i / (CGFloat)valueCount)].CGPath];
    }
    animation.values = [NSArray arrayWithArray:valuesArray];
    animation.duration = self.rotationDuration;
    animation.repeatCount = HUGE_VALF;
    self.animation = animation;
    [self.circleLayer addAnimation:animation forKey:FFProgressIndicatorAnimationKey];
}

#pragma mark - Actions
- (void)stopButtonPressed:(id)sender {
    if (self.isAnimating) {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
