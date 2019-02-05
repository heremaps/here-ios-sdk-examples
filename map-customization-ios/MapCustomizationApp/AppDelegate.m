/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */
#import "AppDelegate.h"
#import <NMAKit/NMAKit.h>

// To obtain the application credentials, please register at https://developer.here.com/develop/mobile-sdks
NSString* const kSampleAppID = @"{App Id}";
NSString* const kSampleAppCode = @"{App Code}";
NSString* const kSampleMapLicenseKey = @"{License Key}";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //set application credentials
    [NMAApplicationContext setAppId:kSampleAppID
                            appCode:kSampleAppCode
                         licenseKey:kSampleMapLicenseKey];
    return YES;
}

@end
