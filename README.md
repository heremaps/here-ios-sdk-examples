[![Build Status](https://travis-ci.com/heremaps/here-ios-sdk-examples.svg?branch=master)](https://travis-ci.com/heremaps/here-ios-sdk-examples)

# HERE Mobile SDK for iOS example projects

Copyright (c) 2011-2019 HERE Europe B.V.

This repository holds a series of Objective-C and Swift projects using the **HERE Mobile SDK for iOS**. More information about the API can be found on [developer.here.com](https://developer.here.com/develop/mobile-sdks) under the *Android & iOS SDKs* section.

This set of self-contained, use-case based projects is designed to be cloned by developers for their own use.

> **Note:** In order to get the sample code to work, you **must** replace all instances of `{YOUR_APP_ID}`, `{YOUR_APP_CODE}` and `{YOUR_LICENSE_KEY}` within the code and use your own **HERE** credentials.

> You can obtain a set of credentials from the [Contact Us](https://developer.here.com/contact-us) page on developer.here.com.**The bundle ID registered must match it in your app**.

## License

Unless otherwise noted in `LICENSE` files for specific files or directories, the [LICENSE](LICENSE) in the root applies to all content in this repository.

## HERE Mobile SDK for iOS (Premium)

All of the following projects use **version 3.13** of the HERE Mobile SDK for iOS (Premium)

* [AutoSuggest](auto-suggest-ios) - Send different types of AutoSuggest requests.
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
* [Search](search-ios) - Send different types of search requests.
* [Turn-by-Turn Navigation](turn-by-turn-navigation-ios) - Trigger a turn-by-turn navigation from HERE Burnaby office to Langley BC.
* [Here Mobile SDK UI Kit](here-mobile-sdk-ui-kit-swift) - Use the HERE Mobile SDK UI Kit (MSDKUI 2.0) to show maneuver instructions, speed limits and current speed.
## How to build apps

### Using CocoaPods

1. Run "pod install" or "pod update" in the application's root directory to install
   the HERE Mobile SDK.

2. In the "General" settings of the App target:
    - Select an eligible provisioning profile or enable "Automatically
      manage signing".

3. In `AppDelegate.m`:
    - Enter an app id, app code and license key.

### Without CocoaPods

1. In the "General" settings of the App target:
    - Select an eligible provisioning profile or enable "Automatically
      manage signing".
    - Add NMAKit.framework to the "Embedded Binaries" section otherwise you
      will get a "dyld: Library not loaded: @rpath/NMAKit.framework/NMAKit"
      error at runtime.

2. In the "Builds Settings" of the App target:
    - Ensure "Frameworks Search Paths" includes the location of
      `NMAKit.framework`.

3. In `AppDelegate.m`:
    - Enter an app id, app code and license key.

## Build Requirements

* XCode 10 or above
* HERE Mobile SDK for iOS (Premium) Version 3.13 or above

## Target Platform

* iOS 11 or above
