/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface MapPackageTableCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel* mapPackageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* mapPackageStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel* mapPackageSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel* mapPackageProgressLabel;

@end
