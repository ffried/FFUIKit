# FFUIKit

[![GitHub release](https://img.shields.io/github/release/ffried/ffuikit.svg?style=flat)](https://github.com/ffried/FFUIKit/releases/latest)
![Tests](https://github.com/ffried/FFUIKit/workflows/Tests/badge.svg)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/2cd8044e536c4aefaf022d6552f94adb)](https://www.codacy.com/app/ffried/FFUIKit?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ffried/FFUIKit&amp;utm_campaign=Badge_Grade)
[![Docs](https://img.shields.io/badge/-documentation-informational)](https://ffried.github.io/FFUIKit)

Some useful additions and classes for Apple's UIKit Framwork.


## Important Note

Release 8.0 is the first step into retiring this framework.
SwiftUI supersedes or provides many things FFUIKit added for UIKit.
Also, UIKit gained support for another bunch of things FFUIKit provided until now.
Finally, the remaining useful parts will be factored out into smaller packages.

The following list provides some help in finding the correct replacement for APIs removed from FFUIKit:

-   The Color Components implementations (`BW`, `BWA`, `RGB`, `RGBA`, `HSB` and `HSBA`) now live in the [Color Components Package](https://github.com/sersoft-gmbh/color-components).
-   `UIDevice.platform` and `UIDevice.platformName` are now found in the [Apple Device Information Package](https://github.com/sersoft-gmbh/apple-device-information).
    `UIDevice.platform` becomes `DeviceInfo.current.identifier` and `platformName` becomes `DeviceInfo.current.name`.
    For SwiftUI, there's the `\.deviceInfo` environment key.
-   `UIStoryboard.Identifier` and the corresponding `instantiateViewController` method were removed in favor of `UIStoryboard`s generic `instantiateViewController` method that already returns a typed view controller.
-   The extensions on `UITableView` allowing animated updates have been soft-deprecated. `UIDiffableDataSource` is a great, more robust and more performant replacement for it.
-   The `LicensesTableViewController`, `LicenseDetailViewController` and `License` model have been replaced in favor of the [Licensed Components Package](https://github.com/sersoft-gmbh/licensed-components).
-   The `UIApplication` extensions for the iTunes URL have been removed in favor of the [App Information Package](https://github.com/sersoft-gmbh/app-information).
-   The `UIColor` extensions have been removed in favor of using [Color Components Package](https://github.com/sersoft-gmbh/color-components), which makes it as easy as of release 1.2.0.
