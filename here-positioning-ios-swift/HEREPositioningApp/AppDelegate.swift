/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

// To obtain the application credentials, please register at https://developer.here.com/develop/mobile-sdks
let kSampleAppID = ""
let kSampleAppCode = ""
let kSampleMapLicenseKey = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //set application credentials
        NMAApplicationContext.setAppId(kSampleAppID, appCode: kSampleAppCode, licenseKey: kSampleMapLicenseKey)
        return true
    }
}
