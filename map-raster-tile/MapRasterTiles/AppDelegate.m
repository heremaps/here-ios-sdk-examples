/*
 * Copyright © 2011-2016 HERE Global B.V. and its affiliate(s).
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import "AppDelegate.h"
#import <NMAKit/NMAKit.h>

// To obtain the application credentials, please register at developer.here.com
NSString* const kSampleAppID = @"{YOUR_APP_ID}";
NSString* const kSampleAppCode = @"{YOUR_APP_CODE}";
NSString* const kSampleMapLicenseKey = @"{YOUR_LICENSE_KEY}";

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    // set application credentials
    [NMAApplicationContext setAppId:kSampleAppID
                            appCode:kSampleAppCode
                         licenseKey:kSampleMapLicenseKey];
    return YES;
}

@end
