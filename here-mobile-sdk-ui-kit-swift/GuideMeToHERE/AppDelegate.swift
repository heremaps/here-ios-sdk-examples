//
// Copyright (C) 2017-2019 HERE Europe B.V.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import NMAKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set credentials (based on bundle identifier).
        let appId = "YOUR_APP_ID"
        let appCode = "YOUR_APP_CODE"
        let licenseKey = "YOUR_LICENSE_KEY"
        let error = NMAApplicationContext.setAppId(appId, appCode: appCode, licenseKey: licenseKey)
        assert(error == NMAApplicationContextError.none, "Please make sure to set valid HERE credentials.")
        return true
    }
}
