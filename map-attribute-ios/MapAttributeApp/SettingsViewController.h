/*
 * Copyright © 2011-2016 HERE Global B.V. and its affiliate(s).
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import <NMAKit/NMAKit.h>
#import <UIKit/UIKit.h>

@class SettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>
- (void)settingsViewControllerDidCancel:(SettingsViewController*)controller;
- (void)settingsViewControllerDidDone:(SettingsViewController*)controller;
@end

@interface SettingsViewController : UITableViewController

@property (nonatomic) NSString* mapScheme;
@property (nonatomic) int trafficLayers;
@property (nonatomic) NMAMapTransitDisplayMode transitDisplayMode;
@property (nonatomic) BOOL streetLevelCoverage;
@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)doneBtPressed:(id)sender;

@end
