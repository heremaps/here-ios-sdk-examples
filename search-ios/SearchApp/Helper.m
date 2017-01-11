/*
 * Copyright (c) 2011-2017 HERE Europe B.V.
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
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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

+ (void)showMessage:(NSString*)message OnView:(UIView*)view
{
    CGRect frame = CGRectMake(110, 200, 220, 120);

    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
