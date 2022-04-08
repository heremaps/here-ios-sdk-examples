# HERE Mobile SDK 3.x for iOS example projects
# Deprecated

Copyright (c) 2011-2022 HERE Europe B.V.

This repository holds a series of Objective-C and Swift projects using the **HERE Mobile SDK for iOS**. More information about the API can be found on [developer.here.com](https://developer.here.com/develop/mobile-sdks) under the *Android & iOS SDKs* section.

Note:
This service is no longer being actively developed. We will only provide critical fixes for this service in future. Instead, use the new [HERE SDK 4.x](https://developer.here.com/documentation/ios-sdk-navigate/4.10.5.0/dev_guide/index.html)
HERE Premium SDK (3.x) is superseded by new 4.x SDK variants and the Premium SDK will be maintained until 31 December 2022 with only critical bug fixes and no feature development / enhancements.
Current users of the HERE Premium SDK (3.x) are encouraged to migrate to Lite, Explore or Navigate HERE SDK (4.x) variants based on licensed use cases before 31 December 2022. Most of the Premium SDK features are already available in the new SDK variants.
Onboarding of new customers for Premium SDK is not possible.

This set of self-contained, use-case based projects is designed to be cloned by developers for their own use.

> **Note:** In order to get the sample code to work, you **must** replace all instances of `{YOUR_APP_ID}`, `{YOUR_APP_CODE}` and `{YOUR_LICENSE_KEY}` within the code and use your own **HERE** credentials.

> You can obtain a set of credentials from the [Contact Us](https://developer.here.com/contact-us) page on developer.here.com.**The bundle ID registered must match it in your app**.

## License

Unless otherwise noted in `LICENSE` files for specific files or directories, the [LICENSE](LICENSE) in the root applies to all content in this repository.

## HERE Mobile SDK for iOS (Premium)

All of the following projects use **version 3.19** of the HERE Mobile SDK for iOS (Premium)

* [AutoSuggest](auto-suggest-ios) - Send different types of AutoSuggest requests.
* [CLE2](cle2-ios) - Use custom location extensions.
* [FTCR](ftcr-routing-ios) - Create a fleet telematics custom route and display it on the map.
* [Geocoding and Reverse Gecoding](geocoder-and-reverse-geocoder-ios) - Trigger a Geocode and Reverse Geocode request in HERE Mobile SDK.
* [Here Positioning](here-positioning-ios) - Use HERE location data source.
* [Map Attribute](map-attribute-ios) - Map attributes manipulations.
* [Map Customization](map-customization-ios) - Customize the map scheme.
* [Map Downloader](map-downloader-ios) - Download offline map data.
* [Map Gestures](map-gestures-ios) - Define custom gesture actions.
* [Map Objects](map-objects-ios) - Add map objects onto HERE map.
* [Map Raster Tile](map-raster-tile-ios) - Add custom raster tiles onto map.
* [Map Rendering](map-rendering-ios) - Display the HERE map on a device.
* [Routing](routing-ios) - Create a route from HERE Burnaby office to Langely BC and display it on the map.
* [Route TTA](route-tta-ios) - Calculate TTA (time to arrival) for a route.
* [SwiftUI](swiftui-ios-swift) - SwiftUI wrapper for map view.
* [Search](search-ios) - Send different types of search requests.
* [Turn-by-Turn Navigation](turn-by-turn-navigation-ios) - Trigger a turn-by-turn navigation from HERE Burnaby office to Langley BC.
* [Here Mobile SDK UI Kit](here-mobile-sdk-ui-kit-swift) - Use the HERE Mobile SDK UI Kit (MSDKUI 2.0) to show maneuver instructions, speed limits and current speed.
## How to build apps

### Using CocoaPods

1. Run "pod install" or "pod update" in the application's root directory to install
   the HERE Mobile SDK. This will integrate NMAKit.xcframework into your project

2. In the "General" settings of the App target:
    - Select an eligible provisioning profile or enable "Automatically
      manage signing".

3. In `AppDelegate.m`:
    - Enter an app id, app code and license key.

### Without CocoaPods

1. In the "General" settings of the App target:
    - Select an eligible provisioning profile or enable "Automatically
      manage signing".
    - Add NMAKit.xcframework to the "Frameworks, Libraries and Embedded Content" section in Xcode. Avoid "Do Not Embed" option. Otherwise you
      will get a "dyld: Library not loaded: @rpath/NMAKit.framework/NMAKit"
      error at runtime.

2. In `AppDelegate.m`:
    - Enter an app id, app code and license key.

## Build Requirements

* Xcode 12 or above
* HERE Mobile SDK for iOS (Premium) Version 3.19 or above

## Target Platform

* iOS 14 or above
