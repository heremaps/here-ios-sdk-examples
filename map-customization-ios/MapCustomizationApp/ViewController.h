/*
 * Copyright (c) 2011-2017 HERE Europe B.V.
 * All rights reserved.
 */
#import <UIKit/UIKit.h>
#import <NMAKit/NMAKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet NMAMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentCtrl;

@end

