/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import <NMAKit/NMAKit.h>

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet NMAMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *createFTCRRouteButton;
@property (nonatomic) NMAFTCRRouter *router;
@property (nonatomic) NMAMapFTCRRoute *mapRoute;

@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // set zoom level
    self.mapView.zoomLevel = 13;
    self.createFTCRRouteButton.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)createFTCRRoute
{
    // Create geo coordinates
    NMAGeoCoordinates *startCoord = [[NMAGeoCoordinates alloc] initWithLatitude:52.484958
                                                                      longitude:13.376825];
    NMAGeoCoordinates *endCoord = [[NMAGeoCoordinates alloc] initWithLatitude:52.4777
                                                                    longitude:13.3777];

    // Create waypoints
    NMAWaypoint *start = [[NMAWaypoint alloc] initWithGeoCoordinates:startCoord];
    NMAWaypoint *end = [[NMAWaypoint alloc] initWithGeoCoordinates:endCoord];

    // Initialize route plan with waypoints
    NMAFTCRRoutePlan *routePlan = [[NMAFTCRRoutePlan alloc] initWithWaypoints:@[start, end]];

    // Initialize the NMAFTCRRouter
    if (!self.router)
    {
        self.router = [NMAFTCRRouter new];
    }

    [self.router calculateRouteWithPlan:routePlan
                        completionBlock:^(NSArray<NMAFTCRRoute *> *routes, NSError *error) {
        if (!error) {
            if (routes.count > 0) {

                // Let's add the 1st ftcr route onto the map
                NMAFTCRRoute *ftcrRoute =  [routes firstObject];
                self.mapRoute = [[NMAMapFTCRRoute alloc] initWithRoute:ftcrRoute];
                [self.mapView addMapObject:self.mapRoute];

                // In order to see the entire route, change the map view bounding box
                [self.mapView setBoundingBox:ftcrRoute.boundingBox
                               withAnimation:NMAMapAnimationBow];
            } else {
                NSLog(@"Error: Returned empty results for ftcr route calculation");
            }
        } else {
            NSLog(@"Error: FTCR route calculation returned error %@", error.userInfo);
        }
    }];
}

- (IBAction)createFTCRRouteButtonDidClick:(id)sender
{
    // Clear map if previous results are still on map.
    if (self.mapRoute)
    {
        [self.mapView removeMapObject:self.mapRoute];
        self.mapRoute = nil;
    }

    [self createFTCRRoute];
}

@end
