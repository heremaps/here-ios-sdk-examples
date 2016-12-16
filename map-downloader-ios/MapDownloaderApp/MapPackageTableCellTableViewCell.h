/*
 * Copyright © 2011-2016 HERE Europe B.V.
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import <UIKit/UIKit.h>

@interface MapPackageTableCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel* mapPackageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* mapPackageStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel* mapPackageSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel* mapPackageProgressLabel;

@end
