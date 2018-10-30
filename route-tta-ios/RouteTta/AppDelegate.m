/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */

#import "AppDelegate.h"
#import <NMAKit/NMAKit.h>

NSString* const kSampleAppID = @"{YOUR_APP_ID}";
NSString* const kSampleAppCode = @"{YOUR_APP_CODE}";
NSString* const kSampleMapLicenseKey = @"{YOUR_LICENSE_KEY}";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NMAApplicationContext setAppId:kSampleAppID
                            appCode:kSampleAppCode
                         licenseKey:kSampleMapLicenseKey];
    return YES;
}

@end
