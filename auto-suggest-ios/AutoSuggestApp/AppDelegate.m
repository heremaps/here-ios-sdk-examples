/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "AppDelegate.h"

// To obtain the application credentials, please register at https://developer.here.com/develop/mobile-sdks
NSString* const kSampleAppID = @"YOUR_APP_ID";
NSString* const kSampleAppCode = @"YOUR_APP_CODE";
NSString* const kSampleMapLicenseKey = @"YOUR_LICENSE_KEY";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //set application credentials
    NMAApplicationContextError error = [NMAApplicationContext setAppId:kSampleAppID
                                                                appCode:kSampleAppCode
                                                             licenseKey:kSampleMapLicenseKey];
    if (error != NMAApplicationContextErrorNone) {
        NSLog(@"Error setting app credentials %lu", error);
    }

    return YES;
}

@end
