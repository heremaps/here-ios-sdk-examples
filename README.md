[![Build Status](https://travis-ci.org/heremaps/here-ios-sdk-examples.svg?branch=master)](https://travis-ci.org/heremaps/here-ios-sdk-examples)

# HERE SDK for iOS example projects

Copyright (c) 2011-2017 HERE Europe B.V.

This repository holds a series of Objective-C-based projects using the **HERE SDK for iOS**. More information about the API can be found on [developer.here.com](https://developer.here.com/develop/mobile-sdks) under the *Android & iOS SDKs* section.

This set of self-contained, use-case based projects is designed to be cloned by developers for their own use.

> **Note:** In order to get the sample code to work, you **must** replace all instances of `{YOUR_APP_ID}`, `{YOUR_APP_CODE}` and `{YOUR_LICENSE_KEY}` within the code and use your own **HERE** credentials.

> You can obtain a set of credentials from the [Contact Us](https://developer.here.com/contact-us) page on developer.here.com.

## License

Unless otherwise noted in `LICENSE` files for specific files or directories, the [LICENSE](LICENSE) in the root applies to all content in this repository.

## iOS Premium SDK

All of the following projects use **version 3.4** of the iOS Premium SDK

* [Geocoding and Reverse Gecoding](geocoder-and-reverse-geocoder-ios) - Trigger a Geocode and Reverse Geocode request in HERE SDK
* [Map Attribute](map-attribute-ios) - Map attributes manipulations
* [Map Customization](map-customization-ios) - Customize the map scheme
* [Map Downloader](map-downloader-ios) - Download offline map data
* [Map Gestures](map-gestures-ios) - Define custom gesture actions
* [Map Objects](map-objects-ios) - Add map objects onto HERE map
* [Map Raster Tile](map-raster-tile) - Add custom raster tiles onto map
* [Map Rendering](map-rendering-ios) - Display the HERE map on a device
* [Routing](rotuing-ios) - Create a route from HERE Burnaby office to Langely BC and display it on the map
* [Search](search-ios) - Send different types of search requests
* [Turn-by-Turn Navigation](turn-by-turn-navigation-ios) - Trigger a turn-by-turn navigation from HERE Burnaby office to Langley BC

## How to build apps 

### Using CocoaPods

1. Run "pod install" or "pod update" in the application's root directory to install
   the HERE SDK.

2. In the "General" settings of the App target:
    - Select an eligible provisioning profile or enable "Automatically
      manage signing".

3. In AppDelegate.m:
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
      NMAKit.framework. In this example app it is already set to
      "$(PROJECT_DIR)/../../framework".
 
3. In AppDelegate.m:
    - Enter an app id, app code and license key.

## Build Requirements
 
* Xcode 8 & iOS 9 SDK or above
* HERE Premium SDK Version 3.4 or above

## Target Platform
 
* iOS 9.0 and above
