/*
 * Copyright (c) 2011-2017 HERE Europe B.V.
 * All rights reserved.
 */


#import "MapViewController.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet NMAMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //create geo coordinate
    NMAGeoCoordinates *geoCoordCenter =
    [[NMAGeoCoordinates alloc] initWithLatitude:49.260327 longitude:-123.115025];
    //set map view with geo center
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    //set zoom level
    self.mapView.zoomLevel = 13.2;
}

@end
