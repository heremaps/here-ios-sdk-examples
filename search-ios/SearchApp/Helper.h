
/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface Helper : NSObject

+ (void)showIndicatorOnView:(UIView*)view;
+ (void)hideIndicator;
+ (void)showMessage:(NSString*)message onView:(UIView*)view;
+ (void)showMessageWithErrorCode:(NSInteger)code domain:(NSString*)domain onView:(UIView*)view;

@end
