//
//  UIAppearance+Swift.h
//  FFUIKit
//
//  Created by Florian Friedrich on 25.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

@import UIKit;

@interface UIView (SwiftAppearance)

+ (instancetype)ffAppearanceWhenContainedInClass:(Class <UIAppearanceContainer>)ContainerClass;
//+ (instancetype)ffAppearanceWhenContainedInClasses:(NSArray *)ContainerClasses; // Class names!

+ (instancetype)ffAppearanceForTraitCollection:(UITraitCollection *)trait whenContainedInClass:(Class <UIAppearanceContainer>)ContainerClass NS_AVAILABLE_IOS(8_0);
//+ (instancetype)ffAppearanceForTraitCollection:(UITraitCollection *)trait whenContainedInClasses:(NSArray *)ContainerClasses NS_AVAILABLE_IOS(8_0); // Class Names

@end
