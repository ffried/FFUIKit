//
//  UIAppearance+Swift.m
//  FFUIKit
//
//  Created by Florian Friedrich on 25.1.15.
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

@implementation UIBarItem (SwiftAppearance)

+ (instancetype)ffAppearanceWhenContainedInClass:(Class<UIAppearanceContainer>)ContainerClass {
    return [self appearanceWhenContainedIn:ContainerClass, nil];
}

+ (instancetype)ffAppearanceForTraitCollection:(UITraitCollection *)trait whenContainedInClass:(Class<UIAppearanceContainer>)ContainerClass {
    return [self appearanceForTraitCollection:trait whenContainedIn:ContainerClass, nil];
}

@end
