
/*
 * Copyright © 2011-2016 HERE Europe B.V.
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import <UIKit/UIKit.h>

@interface Helper : NSObject

+ (void)showIndicatorOnView:(UIView*)view;
+ (void)hideIndicator;
+ (void)showMessage:(NSString*)message OnView:(UIView*)view;

@end
