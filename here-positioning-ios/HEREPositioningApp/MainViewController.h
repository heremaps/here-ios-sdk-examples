/*
 * Copyright (c) 2016-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import <UIKit/UIKit.h>
@import NMAKit;

@interface MainViewController : UIViewController<NMAVenue3dMapLayerDelegate,NMAVenue3dRoutingControllerObserver,
                                                UITableViewDelegate, UITableViewDataSource>

@end
