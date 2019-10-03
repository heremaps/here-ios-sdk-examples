This app shows how several [HERE Mobile SDK UI Kit v2.0](https://github.com/heremaps/msdkui-ios) components can work together to provide a simple user interface for navigation. Once the first valid location of the device is obtained, the app starts navigation to HERE Berlin.

To build and run the app, navigate from the _Terminal_ to your Xcode project folder and execute:
```
pod install --repo-update
```

This will integrate the required dependencies (using CocoaPods):
- HERE Mobile SDK 3.9
- HERE Mobile SDK UI Kit (MSDKUI) 2.0

Once completed, open the Xcode project by double-clicking the newly generated `GuideMeToHERE.xcworkspace` and enter your HERE credentials in `AppDelegate.swift`.

> Did you know that the [MSDKUI library](https://github.com/heremaps/msdkui-ios) provides many more modular UI components to build beautiful user interfaces in no time? It's the perfect companion for the HERE Mobile SDK. And besides, it is open-source, waiting for your contribution. Please click [here](https://github.com/heremaps/msdkui-ios) to find out more.
