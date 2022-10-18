/*
 * Copyright (c) 2016-2021 HERE Europe B.V.
 * All rights reserved.
 */

#import <NMAKit/NMAKit.h>
#import "MainViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) IBOutlet NMAMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Change data source to HERE position data source
    NMAPositioningManager.sharedPositioningManager.dataSource = [[NMAHEREPositionSource alloc] init];

    // Set initial position
    NMAGeoCoordinates *geoCoordCenter = [[NMAGeoCoordinates alloc] initWithLatitude:61.494713 longitude:23.775360];
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];

    self.mapView.copyrightLogoPosition = NMALayoutPositionBottomCenter;

    // Set zoom level
    self.mapView.zoomLevel = NMAMapViewMaximumZoomLevel - 1;

    // Subscribe to position updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePosition)
                                                 name:NMAPositioningManagerDidUpdatePositionNotification
                                               object:[NMAPositioningManager sharedPositioningManager]];

    // Set position indicator visible. Also starts position updates.
    self.mapView.positionIndicator.visible = YES;
}

- (void)didUpdatePosition {
    NMAGeoPosition *position = [[NMAPositioningManager sharedPositioningManager] currentPosition];
    NSString *text = [NSString stringWithFormat:
                      @" Type: %@\n Coordinate: %.6f, %.6f\n Altitude: %.1f\n",
                      position.source == NMAGeoPositionSourceIndoor ? @"Indoor" :
                      position.source == NMAGeoPositionSourceSystemLocation ? @"System" :
                      @"Unknown",
                      position.coordinates.latitude,
                      position.coordinates.longitude,
                      position.coordinates.altitude];

    if (position.buildingName && position.buildingId) {
        NSString *tempString = [NSString stringWithFormat:
                           @" Building: %@ (%@)\n",
        position.buildingName,
        position.buildingId];

        text = [text stringByAppendingString:tempString];
    }

    if (position.floorId) {
        NSString *tempString = [NSString stringWithFormat:
                           @" Floor: %@",
        position.floorId];

        text = [text stringByAppendingString:tempString];
    }
    // Update label text based on received position.
    self.label.text = text;

    // Update map center to initial valid position
    [_mapView setGeoCenter:position.coordinates
             withAnimation:NMAMapAnimationLinear];
}

@end
