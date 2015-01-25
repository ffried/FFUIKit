//
//  UIAppearance+Swift.m
//  FFUIKit
//
//  Created by Florian Friedrich on 25.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

#import "UIAppearance+Swift.h"

@implementation UIView (SwiftAppearance)

+ (instancetype)ffAppearanceWhenContainedInClass:(Class<UIAppearanceContainer>)ContainerClass {
    return [self appearanceWhenContainedIn:ContainerClass, nil];
//    return [self ffAppearanceWhenContainedInClasses:@[NSStringFromClass(ContainerClass)]];
}

//+ (instancetype)ffAppearanceWhenContainedInClasses:(NSArray *)ContainerClasses {
//    NSUInteger count = [ContainerClasses count];
//    Class<UIAppearanceContainer> classes[count];
//    for (NSUInteger idx = 0; idx < count; idx++) {
//        NSString *name = ContainerClasses[idx];
//        Class c = NSClassFromString(name);
//        NSAssert([c conformsToProtocol:@protocol(UIAppearanceContainer)],
//                 @"Classes have to conform to %@, but %@ does not!",
//                 NSStringFromProtocol(@protocol(UIAppearanceContainer)),
//                 NSStringFromClass(c));
//        classes[idx] = c;
//    }
//    return [self appearanceWhenContainedIn:classes, nil];
//}

+ (instancetype)ffAppearanceForTraitCollection:(UITraitCollection *)trait whenContainedInClass:(Class<UIAppearanceContainer>)ContainerClass {
    return [self appearanceForTraitCollection:trait whenContainedIn:ContainerClass, nil];
}

@end
