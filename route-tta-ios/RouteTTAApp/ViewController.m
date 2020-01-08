/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /* Initialize a CoreRouter */
    self.coreRouter = [[NMACoreRouter alloc] init];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NMATrafficManager sharedTrafficManager] removeObserver:self];
}

- (IBAction)calculateRoute:(UIButton *)sender {
    /* Define waypoints for the route */
    /* START: Holländerstraße, Wedding, 13407 Berlin */
    NMAGeoCoordinates* startPoint = [[NMAGeoCoordinates alloc] initWithLatitude:52.562755700200796 longitude:13.34599438123405];
    
    /* MIDDLE: Lynarstraße 3 */
    NMAGeoCoordinates* middlePoint = [[NMAGeoCoordinates alloc] initWithLatitude:52.54172 longitude:13.36354];
    
    /* END: Agricolastraße 29, 10555 Berlin */
    NMAGeoCoordinates* endPoint = [[NMAGeoCoordinates alloc] initWithLatitude: 52.520720371976495 longitude: 13.332345457747579];
    
    /* Initialize a RoutePlan */
    NSArray* routePlan = [NSArray arrayWithObjects:startPoint, middlePoint, endPoint, nil];
    
    /*
     * Initialize a RouteOption. HERE Mobile SDK allows users to define their own parameters for the
     * route calculation,including transport modes,route types and route restrictions etc.Please
     * refer to API doc for full list of APIs
     */
    
    NMARoutingMode* routeMode = [[NMARoutingMode alloc] init];
    /* Other transport modes are also available e.g Pedestrian */
    routeMode.transportMode = NMATransportModeCar;
    /* Disable highway in this route. */
    routeMode.routingOptions = NMARoutingOptionAvoidHighway;
    /* Calculate the fastest route available. */
    routeMode.routingType = NMARoutingTypeFastest;
    /* Calculate 1 route. */
    routeMode.resultLimit = 1;
    
    // for calculating traffic on the route
    NMADynamicPenalty* penalty = [[NMADynamicPenalty alloc] init];
    penalty.trafficPenaltyMode = NMATrafficPenaltyModeOptimal;
    _coreRouter.dynamicPenalty = penalty;
    
    [_coreRouter calculateRouteWithStops:routePlan routingMode:routeMode completionBlock:
     ^(NMARouteResult * _Nullable routeResult, NMARoutingError error) {
         NMARoute* route = routeResult.routes[0];
         
         // check if route exist
         if (route == nil) {
             return;
         }
         
         self.calculatedRoute = route;
         
         if (self.mapRoute != nil) {
             [self.mapView removeMapObject:self.mapRoute];
         }
         
         // add route on the map
         self.mapRoute = [[NMAMapRoute alloc] initWithRoute:self.calculatedRoute];
         [self.mapView addMapObject:self.mapRoute];
         [self.mapView setBoundingBox:route.boundingBox withAnimation:NMAMapAnimationNone];
         
         // start downloading traffic for route
         const NMATrafficManager* const manager = [NMATrafficManager sharedTrafficManager];
         [manager requestTrafficOnRoute:route];
         [manager addObserver:self];
         [self setTtaTime];
     }];
}

- (void)setTtaTime {
    const NSTimeInterval timeIncluded = [_calculatedRoute ttaIncludingTrafficForSubleg:NMARouteSublegWhole].duration;
    const NSTimeInterval timeExcluded = [_calculatedRoute ttaExcludingTrafficForSubleg:NMARouteSublegWhole].duration;
    self.includedLabel.text = [NSString stringWithFormat:@"ttaIncluded:%.f", timeIncluded];
    self.excludedLabel.text = [NSString stringWithFormat:@"ttaExcluded:%.f", timeExcluded];
}

- (void)trafficDataDidFinish {
    const NSTimeInterval timeDownloaded = [_calculatedRoute ttaUsingDownloadedTrafficForSubleg:NMARouteSublegWhole].duration;
    self.downloadedLabel.text = [NSString stringWithFormat:@"ttaDownloaded:%.f", timeDownloaded];
}

@end
