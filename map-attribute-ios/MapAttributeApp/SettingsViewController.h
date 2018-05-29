/*
 * Copyright (c) 2011-2017 HERE Europe B.V.
 * All rights reserved.
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
@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)doneBtPressed:(id)sender;

@end
