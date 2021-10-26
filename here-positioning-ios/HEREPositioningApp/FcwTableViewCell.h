/*
 * Copyright (c) 2016-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface FcwTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *floorName;
@property (weak, nonatomic) IBOutlet UIView *groundFloorIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *currentFloorIndicator;

@end
