/*
 * Copyright (c) 2016-2017 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import <NMAKit/NMAKit.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *label;
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

    // Update label text based on received position.
    self.label.text = [NSString stringWithFormat:
                       @" Type: %@\n Coordinate: %.6f, %.6f\n Altitude: %.1f\n Building: %@ (%@)\n Floor: %@",
        position.source == NMAGeoPositionSourceIndoor ? @"Indoor" :
        position.source == NMAGeoPositionSourceSystemLocation ? @"System" :
                                                        @"Unknown",
        position.coordinates.latitude,
        position.coordinates.longitude,
        position.coordinates.altitude,
        position.buildingName,
        position.buildingId,
        position.floorId];

    // Update position indicator position.
    [_mapView setGeoCenter:position.coordinates
             withAnimation:NMAMapAnimationLinear];
}


@end
