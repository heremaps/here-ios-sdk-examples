/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import "SettingsViewController.h"
#import <NMAKit/NMAKit.h>

@interface MainViewController () <SettingsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet NMAMapView* mapView;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/**
 * Notifies the view controller that a segue is about to be performed
 **/
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{ // navigate to SettingsViewController
    if ([segue.identifier isEqualToString:@"Settings"])
    {
        UINavigationController* navigationController = segue.destinationViewController;
        SettingsViewController* settingsController =
            [[navigationController viewControllers] objectAtIndex:0];
        // Set current view controller to be SettingsViewController's delegate
        settingsController.delegate = self;
        // It shows current selections of map view's map scheme, transit display mode and whether
        // traffic is visible in settings.
        settingsController.mapScheme = _mapView.mapScheme;
        settingsController.transitDisplayMode = _mapView.transitDisplayMode;
        // If tranfic is visible, it turns on/off traffic layer switch in settings
        if (_mapView.isTrafficVisible)
        {
            if ([_mapView isTrafficLayerVisible:NMATrafficLayerFlow])
            {
                settingsController.trafficLayers ^= NMATrafficLayerFlow;
            }
            if ([_mapView isTrafficLayerVisible:NMATrafficLayerIncidents])
            {
                settingsController.trafficLayers ^= NMATrafficLayerIncidents;
            }
        }
    }
}

/**
 * When cancel button is clicked in setting, it dismisses settings view.
 **/
- (void)settingsViewControllerDidCancel:(SettingsViewController*)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * When done button is clicked in setting, it applied selection from settings and then dismisses
 *settings view
 **/
- (void)settingsViewControllerDidDone:(SettingsViewController*)controller
{
    [self applySettings:controller];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * Apply all the selections of map attributes from settings view to current map view.
 **/
- (void)applySettings:(SettingsViewController*)controller
{ // set current map view's scheme
    [self.mapView setMapScheme:controller.mapScheme];
    // If traffic layers are selected, then turn on traffic visible and set traffic layers
    if (controller.trafficLayers > 0)
    {

        [self.mapView setTrafficVisible:YES];

        (controller.trafficLayers & NMATrafficLayerFlow)
            ? [self.mapView showTrafficLayers:NMATrafficLayerFlow]
            : [self.mapView hideTrafficLayers:NMATrafficLayerFlow];

        (controller.trafficLayers & NMATrafficLayerIncidents)
            ? [self.mapView showTrafficLayers:NMATrafficLayerIncidents]
            : [self.mapView hideTrafficLayers:NMATrafficLayerIncidents];
    }
    else
    {
        [self.mapView setTrafficVisible:NO];
    }
    // Set selected transit display mode.
    self.mapView.transitDisplayMode = controller.transitDisplayMode;
}
@end
