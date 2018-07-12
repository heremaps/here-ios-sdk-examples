/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */

import NMAKit

// To obtain the application credentials, please register at https://developer.here.com/develop/mobile-sdks
let kSampleAppID = "DuBE2XNNpcj54jGYS2eL"
let kSampleAppCode = "q0xXnNZoeEkXoVxBpQ5E2Q"
let kSampleMapLicenseKey = "ZCn9hQiJPm61AlrL5A6Mi/IWvvVqZ0dbCZ+S+qVL1g/quQprgsAdl9mxx6quASuo5ryDI6rrLKboj/Edf9Nk7HWKGpSA0GI1/sllwNTHnMrl6cxjjsQRyaRPp6WCFjRQHDNZf1qOi3l0YCg1sx83axQRVekhBOmk/rQmcgafhshXDhWWIKbd5LG6KzBg/C1J7VL/kjyMJ8jmMSz0YlqDmiz8iDOaOv0DfXXs3fkMj8GZOF8OHOn/2t6RFPKX2wHeQxUHJbqna8Mv0ti0OW4QUg8I++0EJcYrHNCrzNS96aEyBUcAY8lALarZbpEuZ8jwJtgwbuvbT8Mh3QlBctWF2DZfwoa1mQX6xHJJYlkDseo0rMmxdqgZ+RYMebpMhfixxkOpwYI0/rAAX2m38EBkUuqhWsjJOIbe7jsCSGCc9ZSfZJrgAkFxUqhVwm58Jcwr/ZMBm7EN1FkY4T3U9qWgSnQBACejEvY1O1rMof5h0cDvMAkEbq5WQ7pGsGoIbLRQKnWcNMETVaIHMhtMGqz1hZQK5FDeL2Ets83wMe14qYXWLwmkK3HDGHG5rDpbcdbeE7ElnwC4dbCoYzxM0idVWSawu0zPEIg7IGi1BM9hBH8NQAL5vUJ+h2gstzZvpjrvw/RSNq6FJa4vFfNPu2XkmvegHaY+ok4pbnMWu8/kxz8="

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        NMAApplicationContext.setAppId(kSampleAppID, appCode: kSampleAppCode, licenseKey: kSampleMapLicenseKey)

        return true
    }
}

