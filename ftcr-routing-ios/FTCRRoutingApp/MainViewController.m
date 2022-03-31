/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import <NMAKit/NMAKit.h>

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet NMAMapView *mapView;
@property (nonatomic) NMAFTCRRouter *ftcrRouter;
@property (nonatomic) NMAMapFTCRRoute *mapRoute;

@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set zoom level
    self.mapView.zoomLevel = 13;

    // Initialize the NMAFTCRRouter
    self.ftcrRouter = [NMAFTCRRouter new];
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

    //Setup additional options
    NMAFTCRRouteOptions *routeOptions = [NMAFTCRRouteOptions new];
    routeOptions.transportMode = NMAFTCRTransportModeCar;
    routeOptions.routingType = NMAFTCRRoutingTypeFastest;
    routeOptions.departureTime = [NSDate date];
    routeOptions.tunnelsAvoidance = NMAFTCRRouteAvoidanceAvoid;

    routePlan.options = routeOptions;

    [self.ftcrRouter calculateRouteWithPlan:routePlan
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

- (IBAction)createFTCRRouteButtonClicked:(id)sender
{
    // Clear map if previous result is still on the map
    if (self.mapRoute) {
        [self.mapView removeMapObject:self.mapRoute];
        self.mapRoute = nil;
    }

    [self createFTCRRoute];
}

@end
