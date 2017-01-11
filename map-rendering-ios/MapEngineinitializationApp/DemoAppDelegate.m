/*
 * Copyright (c) 2011-2017 HERE Europe B.V.
 * All rights reserved.
 */


#import "DemoAppDelegate.h"
#import <NMAKit/NMAKit.h>

// To obtain the application credentials, please register at developer.here.com
NSString* const kSampleAppID = @"{YOUR_APP_ID}";
NSString* const kSampleAppCode = @"{YOUR_APP_CODE}";
NSString* const kSampleMapLicenseKey = @"{YOUR_LICENSE_KEY}";

@implementation DemoAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   //set application credentials
   [NMAApplicationContext setAppId:kSampleAppID
                            appCode:kSampleAppCode
                         licenseKey:kSampleMapLicenseKey];
    
    return YES;
}

@end
