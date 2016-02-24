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

