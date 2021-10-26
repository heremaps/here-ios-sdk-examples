/*
 * Copyright (c) 2011-2021 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import <NMAKit/NMAKit.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *showEnvZones;
@property (weak, nonatomic) IBOutlet NMAMapView* mapView;
@property (weak, nonatomic) IBOutlet UIButton* createRouteButton;
@property (nonatomic) NMACoreRouter* router;
@property (nonatomic) NMAMapRoute* mapRoute;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // create geo coordinate
    NMAGeoCoordinates* geoCoordCenter =
        [[NMAGeoCoordinates alloc] initWithLatitude:52.406425 longitude:13.193975];
    // set map view with geo center
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    // set zoom level
    self.mapView.zoomLevel = 13.2;
    self.createRouteButton.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

- (void)createRoute
{
    // Create an NSMutableArray to add two stops
    NSMutableArray* stops = [[NSMutableArray alloc] initWithCapacity:4];

    // START: South of Berlin
    NMAGeoCoordinates* hereBurnaby =
        [[NMAGeoCoordinates alloc] initWithLatitude:52.406425 longitude:13.193975];
    // END: North of Berlin
    NMAGeoCoordinates* langley =
        [[NMAGeoCoordinates alloc] initWithLatitude:52.638623 longitude:13.441998];
    [stops addObject:hereBurnaby];
    [stops addObject:langley];

    // Create an NMARoutingMode, then set it to find the fastest car route without going on Highway.
    NMARoutingMode* routingMode =
        [[NMARoutingMode alloc] initWithRoutingType:NMARoutingTypeFastest
                                      transportMode:NMATransportModeCar
                                     routingOptions:NMARoutingOptionAvoidHighway];

    // Initialize the NMACoreRouter
    if ( !self.router )
    {
        self.router = [[NMACoreRouter alloc] init];
    }

    // Use banned areas if needed
    [self addBannedAreasForCoreRouter:self.router];

    // Trigger the route calculation
    [self.router
        calculateRouteWithStops:stops
                    routingMode:routingMode
                completionBlock:^( NMARouteResult* routeResult, NMARoutingError error ) {
                  if ( !error )
                  {
                      if ( routeResult && routeResult.routes.count >= 1 )
                      {
                          // Let's add the 1st result onto the map
                          NMARoute* route = routeResult.routes[0];
                          self.mapRoute = [NMAMapRoute mapRouteWithRoute:route];
                          [self.mapView addMapObject:self.mapRoute];

                          // In order to see the entire route, we orientate the map view
                          // accordingly
                          [self.mapView setBoundingBox:route.boundingBox
                                         withAnimation:NMAMapAnimationLinear];
                      }
                      else
                      {
                          NSLog( @"Error:route result returned is not valid" );
                      }
                  }
                  else
                  {
                      NSLog( @"Error:route calculation returned error code %d", (int)error );
                  }
                }];
}

- (void)addBannedAreasForCoreRouter:(NMACoreRouter *)router
{
    // Example of usage banned areas API
    NMADynamicPenalty* dynamicPenalty = [[NMADynamicPenalty alloc] init];
    // There are two options to avoid certain areas during routing,
    // 1. Add banned area using addBannedArea API
    NSArray* coordinates = @[
        [[NMAGeoCoordinates alloc] initWithLatitude:52.631692 longitude:13.437591],
        [[NMAGeoCoordinates alloc] initWithLatitude:52.631905 longitude:13.437787],
        [[NMAGeoCoordinates alloc] initWithLatitude:52.632577 longitude:13.438357]];

    NMAGeoPolygon* geoPolygon = [[NMAGeoPolygon alloc] initWithCoordinates:coordinates];
    // Note, the maximum supported number of banned areas is 20.
    [dynamicPenalty addBannedArea:[[NMAMapPolygon alloc] initWithPolygon:geoPolygon]];

    // 2. Add banned road link using addPenaltyForRoadElement API
    // Note, map data needs to be present to get RoadElement by the GeoCoordinate.
    NMARoadElement* roadElement = [self.mapView roadElementAtCoordinates:
        [[NMAGeoCoordinates alloc] initWithLatitude:52.406611 longitude:13.194916]];
    if (roadElement) {
        // use speed = 0 to completely exclude road link from routing
        [dynamicPenalty addPenaltyForRoadElement:roadElement
                            withDrivingDirection:NMADrivingDirectionBoth
                                           speed:0];
    }

    router.dynamicPenalty = dynamicPenalty;
}

- (IBAction)buttonDidClicked:(id)sender
{
    // Clear map if previous results are still on map, otherwise proceed to creating route
    if ( self.mapRoute )
    {
        [self.mapView removeMapObject:self.mapRoute];
        self.mapRoute = nil;
    }
    else
    {
        [self createRoute];
    }
}
- (IBAction)didEnvZoneChanged:(id)sender {
    if (_showEnvZones.on) {
        [_mapView showFleetFeature:NMAMapFleetFeatureTypeEnvironmentalZones];
    } else {
        [_mapView hideFleetFeature:NMAMapFleetFeatureTypeEnvironmentalZones];
    }
}

@end
