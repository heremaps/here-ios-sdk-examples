/*
 * Copyright (c) 2016-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "FcwTableViewCell.h"

@implementation FcwTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *groundFloorIndicatorColor = _groundFloorIndicator.backgroundColor;
    UIColor *currentFloorIndicatorColor = _currentFloorIndicator.backgroundColor;
    [super setSelected:selected animated:animated];
    if (selected){
        _groundFloorIndicator.backgroundColor = groundFloorIndicatorColor;
        _currentFloorIndicator.backgroundColor = currentFloorIndicatorColor;
    }
}

@end
