/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView *mapView;
@property (strong, nonatomic) NMACoreRouter *router;
@property (strong, nonatomic) NMARoute *route;
@property (strong, nonatomic) NMAMapRoute *mapRoute;
@property (strong, nonatomic) NMAGeoBoundingBox *geoBoundingBox;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) NMAMapDataPrefetcher *prefetcher;
@end

NSUInteger const radius = 600.0;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _activityView = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _activityView.hidesWhenStopped = YES;
    _activityView.center = self.view.center;
    [self.view addSubview:_activityView];
    
    _prefetcher = NMAMapDataPrefetcher.sharedMapDataPrefetcher;
    
    [_prefetcher addListener:self];
    
    // create geo coordinate
    NMAGeoCoordinates* geoCoordCenter =
    [[NMAGeoCoordinates alloc] initWithLatitude:49.260327 longitude:-123.0];
    
    // set map view with geo center
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    
    // set zoom level
    self.mapView.zoomLevel = 12.0;
}

#pragma mark - Buttons action

- (IBAction)createRoute:(id)sender {
    NMAGeoCoordinates* hereBurnaby =
    [[NMAGeoCoordinates alloc] initWithLatitude:49.264178 longitude:-123.117542];
    
    NMAGeoCoordinates* langley =
    [[NMAGeoCoordinates alloc] initWithLatitude:49.229185 longitude:-123.094052];
    
    NSArray *stops = @[hereBurnaby, langley];
    
    NMARoutingMode* routingMode =
    [[NMARoutingMode alloc] initWithRoutingType:NMARoutingTypeFastest
                                  transportMode:NMATransportModeCar
                                 routingOptions:0];
    
    // Initialize the NMACoreRouter
    if ( !self.router )
    {
        self.router = [[NMACoreRouter alloc] init];
    }
    
    // Avoid retain cycle of self object
    __weak __typeof__(self) weakSelf = self;
    // Trigger the route calculation
    [self.router
     calculateRouteWithStops:stops
     routingMode:routingMode
     completionBlock:^( NMARouteResult* routeResult, NMARoutingError error ) {
        // make strong self object for method calls in block
        __typeof__(self) strongSelf = weakSelf;
        if ( !error ) {
            if ( routeResult && routeResult.routes.count > 0 ) {
                // Let's add the 1st result onto the map
                strongSelf.route = routeResult.routes[0];
                [strongSelf updateMapRouteWithRoute:strongSelf.route];
            } else {
                [strongSelf showMessageWithTitle:@"Error"
                                         message:@"RouteResult is nil."];
            }
        } else {
            [strongSelf showMessageWithTitle:@"Error"
                                     message:
             [NSString stringWithFormat:@"Error:route calculation returned error code %d",
              (int)error]];
        }
    }];
}

- (IBAction)estimateBoundingBox:(id)sender {
    if (self.mapView.boundingBox == nil) {
        [self showMessageWithTitle:@"Error" message:@"Can't get bounding box."];
        return;
    }
    
    [self activityProcess];
    
    NSUInteger error = NMAPrefetchRequestErrorUnknown;
    [_prefetcher estimateMapDataSizeForBoundingBox:self.mapView.boundingBox error:&error];
    
    if (error != NMAPrefetchRequestErrorNone) {
        [self showMessageWithTitle:@"Error"
                           message:[NSString stringWithFormat:@"Can't estimate area. Error code: %d",
                                    (int)error]];
        return;
    }
}

- (IBAction)fetchBoundingBox:(id)sender {
    if (self.mapView.boundingBox == nil) {
        [self showMessageWithTitle:@"Error" message:@"Can't get bounding box."];
        return;
    }
    
    [self activityProcess];
    
    NSUInteger error = NMAPrefetchRequestErrorUnknown;
    [_prefetcher fetchMapDataForBoundingBox:self.mapView.boundingBox error:&error];
    
    if (error != NMAPrefetchRequestErrorNone) {
        [self showMessageWithTitle:@"Error"
                           message:[NSString stringWithFormat:@"Can't estimate area. Error code: %d",
                                    (int)error]];
        return;
    }
}

- (IBAction)estimateRoute:(id)sender {
    if (!_route) {
        [self showMessageWithTitle:@"Error" message:@"Route is nil, press on \"Create route\"."];
        return;
    }
    
    [self activityProcess];
    
    NSUInteger error = NMAPrefetchRequestErrorUnknown;
    
    [_prefetcher estimateMapDataSizeForRoute:_route radius:radius error:&error];
    
    if (error != NMAPrefetchRequestErrorNone) {
        [self showMessageWithTitle:@"Error"
                           message:[NSString stringWithFormat:@"Can't estimate route. Error code: %d",
                                    (int)error]];
        return;
    }
    [self showRoute];
}

- (IBAction)fetchRoute:(id)sender {
    if (!_route) {
        [self showMessageWithTitle:@"Error" message:@"Route is nil, press on \"Create route\"."];
        return;
    }
    
    [self activityProcess];
    
    NSUInteger error = NMAPrefetchRequestErrorUnknown;
    
    [_prefetcher fetchMapDataForRoute:_route radius:radius error:&error];
    
    if (error != NMAPrefetchRequestErrorNone) {
        [self showMessageWithTitle:@"Error"
                           message:[NSString stringWithFormat:@"Can't estimate route. Error code: %d",
                                    (int)error]];
        return;
    }
    [self showRoute];
}

#pragma mark - NMAMapDataPrefetcherListener
- (void)prefetcher:(NMAMapDataPrefetcher *)prefetcher didEstimate:(NSInteger)dataSizeKB
      forRequestId:(NSInteger)requestId withSuccess:(BOOL)success
{
    if (success) {
        NSString *message = dataSizeKB > 0
        ? [NSString stringWithFormat:@"Estimated size for this region is %ld KB", (long)dataSizeKB]
        : @"This region is already fetched.";
        [self showMessageWithTitle:@"Success" message:message];
        return;
    }
    [self showMessageWithTitle:@"Error" message:@"Estimation isn't success."];
}

- (void)prefetcher:(NMAMapDataPrefetcher *)prefetcher didUpdateProgress:(float)progress
      forRequestId:(NSInteger)requestId
{
    if (progress == 1.0) {
        [self showMessageWithTitle:@"Success" message:@"This region is fetched."];
    }
}
#pragma mark - Route functions

- (void)showRoute
{
    if ( _route != nil && _route.boundingBox != nil) {
        _geoBoundingBox = _route.boundingBox;
        [_mapView setBoundingBox:_route.boundingBox withAnimation:NMAMapAnimationLinear];
        return;
    }
    
    [self showMessageWithTitle:@"Error" message:@"Route is nil, try again."];
}

- (void)updateMapRouteWithRoute:(NMARoute *)route
{
    // remove previously created map route from map
    if (self.mapRoute) {
        [self.mapView removeMapObject:self.mapRoute];
    }
    // create new one based on provided route
    if (route) {
        self.mapRoute = [NMAMapRoute mapRouteWithRoute:route];
        self.mapRoute.traveledColor = [UIColor clearColor];
        [self.mapView addMapObject:self.mapRoute];
        
        // In order to see the entire route, we orientate the
        // map view accordingly
        [self showRoute];
    }
}

#pragma mark - UI utility

- (void)activityProcess
{
    self.view.userInteractionEnabled = NO;
    [_activityView startAnimating];
}

- (void)showMessageWithTitle:(NSString*)title
                     message:(NSString*)message
{
    [_activityView stopAnimating];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    self.view.userInteractionEnabled = YES;
}

@end
