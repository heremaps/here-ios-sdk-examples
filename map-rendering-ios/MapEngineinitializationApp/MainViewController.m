/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */


#import "MainViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet NMAMapView *mapView;

@end

@implementation MainViewController

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
