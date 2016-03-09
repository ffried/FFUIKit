//
//  UIAppearance+Swift.h
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

@import UIKit;

@protocol FFAppearance <UIAppearance>

+ (instancetype)ffAppearanceWhenContainedInClass:(Class <UIAppearanceContainer>)ContainerClass;
//+ (instancetype)ffAppearanceWhenContainedInClasses:(NSArray *)ContainerClasses; // Class names!

+ (instancetype)ffAppearanceForTraitCollection:(UITraitCollection *)trait whenContainedInClass:(Class <UIAppearanceContainer>)ContainerClass NS_AVAILABLE_IOS(8_0);
//+ (instancetype)ffAppearanceForTraitCollection:(UITraitCollection *)trait whenContainedInClasses:(NSArray *)ContainerClasses NS_AVAILABLE_IOS(8_0); // Class Names

@end

@interface UIView (SwiftAppearance) <FFAppearance>
@end

@interface UIBarItem (SwiftAppearance) <FFAppearance>
@end
