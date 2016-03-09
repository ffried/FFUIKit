//
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

//: Playground - noun: a place where people can play

import FFUIKit

let greenColor = UIColor.greenColor()
let blueColor = UIColor.blueColor()
let purpleColor = UIColor.purpleColor()
var components = ColorComponents.blackHSBA
components.updateFromColor(greenColor)
components
components.updateFromColor(blueColor)
components
components.updateFromColor(purpleColor)
components

let blueImage = UIImage(color: blueColor, size: CGSize(width: 50, height: 50))
let testImg = UIImage(named: "TestImg.png")
let mergedColor = testImg?.mergedColor
let avgColor = testImg?.averageColor
let tintedImg = testImg?.imageTintedWithColor(purpleColor)
let roundedImg = testImg?.imageByRoundingCornersTo(500.0)

let hexColor = UIColor(hexString: "0xFFFFFF00")

