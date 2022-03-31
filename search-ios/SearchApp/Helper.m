/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */
#import "Helper.h"

@implementation Helper

static UIActivityIndicatorView* indicator;

+ (void)showIndicatorOnView:(UIView*)view
{
    if (!indicator)
    {
        indicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    }
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = view.center;
    [view addSubview:indicator];
    [view bringSubviewToFront:indicator];

    [indicator startAnimating];
}

+ (void)hideIndicator
{
    if (indicator)
    {
        [indicator stopAnimating];
    }
}

+ (void)showMessageWithErrorCode:(NSInteger)code domain:(NSString*)domain onView:(UIView*)view
{
    [Helper showMessage:[NSString stringWithFormat:@"Error:%@ request fired with error code %zd",
                         domain, code]
                 onView:view];
}

+ (void)showMessage:(NSString*)message onView:(UIView*)view
{
    CGRect frame = CGRectMake(110, 200, 220, 120);

    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor systemGroupedBackgroundColor];
    label.textColor = [UIColor blueColor];
    label.text = message;
    label.numberOfLines = 0;

    CGRect rect = [[label text]
        boundingRectWithSize:frame.size
                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                  attributes:@{
                      NSFontAttributeName : label.font
                  }
                     context:nil];
    frame.size = rect.size;
    label.frame = frame;

    [view addSubview:label];

    [UIView animateWithDuration:2.0
        animations:^{
            label.alpha = 0;
        }
        completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
}

@end
