/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

#import "AppDelegate.h"
#import <NMAKit/NMAKit.h>

// To obtain the application credentials, please register at https://developer.here.com/develop/mobile-sdks
NSString* const kSampleAppID = @"{YOUR_APP_ID}";
NSString* const kSampleAppCode = @"{YOUR_APP_CODE}";
NSString* const kSampleMapLicenseKey = @"{YOUR_LICENSE_KEY}";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NMAApplicationContext setAppId:kSampleAppID
                            appCode:kSampleAppCode
                         licenseKey:kSampleMapLicenseKey];
    return YES;
}

@end
