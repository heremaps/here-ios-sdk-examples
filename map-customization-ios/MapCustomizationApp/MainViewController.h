/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <NMAKit/NMAKit.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet NMAMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentCtrl;
@property (strong) NMACustomizableScheme* colorScheme;
@property (strong) NMACustomizableScheme* floatScheme;

@end

