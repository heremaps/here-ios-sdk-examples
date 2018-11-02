/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <NMAKit/NMAKit.h>

@interface ViewController : UIViewController <NMATrafficManagerObserver>

@property (strong, nonatomic) NMARoute* calculatedRoute;
@property (strong, nonatomic) NMACoreRouter* coreRouter;
@property (strong, nonatomic) NMAMapRoute* mapRoute;
@property (weak, nonatomic) IBOutlet NMAMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *excludedLabel;
@property (weak, nonatomic) IBOutlet UILabel *includedLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadedLabel;

@end
