/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

let credentials = (
    appId: "",
    appCode: "",
    licenseKey: ""
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NMAApplicationContext.setAppId(credentials.appId, appCode: credentials.appCode, licenseKey: credentials.licenseKey)
        return true
    }
}
