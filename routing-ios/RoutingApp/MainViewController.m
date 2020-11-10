/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
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
