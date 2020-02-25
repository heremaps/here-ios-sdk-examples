/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *navigationControlButton;
@property (strong, nonatomic) NMANavigationManager *navigationManager;
@property (strong, nonatomic) NMACoreRouter *router;
@property (strong, nonatomic) NMARoute *route;
@property (strong, nonatomic) NMAMapRoute *mapRoute;
@property (strong, nonatomic) NMAGeoBoundingBox *geoBoundingBox;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // create geo coordinate
    NMAGeoCoordinates* geoCoordCenter =
        [[NMAGeoCoordinates alloc] initWithLatitude:49.260327 longitude:-123.115025];
    // set map view with geo center
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    // set zoom level
    self.mapView.zoomLevel = 13.2;
    [self.navigationControlButton setTitle:@"Start Navigation" forState:UIControlStateNormal];
    self.navigationControlButton.titleLabel.adjustsFontSizeToFitWidth = YES;

    // Get the NavigationManager instance.It is responsible for providing voice and visual
    // instructions while driving and walking.
    self.navigationManager = NMANavigationManager.sharedNavigationManager;

    // Set this controller to be the delegate of NavigationManager, so that it can listening to the
    // navigation events through the different protocols.In this example, we will
    // implement 2 protocol methods for demo purpose, please refer to HERE Mobile SDK for iOS API documentation
    // for details
    self.navigationManager.delegate = self;
    self.navigationManager.speedWarningEnabled = YES;
}

#pragma mark - User actions

- (IBAction)navigationControlButton:(id)sender
{
    // To start a turn-by-turn navigation, a concrete route object is required.We use same steps
    // from Routing sample app to create a route from 4350 Still Creek Dr to Langley BC without
    // going on HWY
    // The route calculation requires local map data.Unless there is pre-downloaded map
    // data on device by utilizing MapLoader APIs,it's not recommended to trigger the
    // route calculation immediately after the MapEngine is initialized.The
    // NMARoutingErrorInsufficientMapData error code may be returned by CoreRouter in this case.
    if ( !self.route )
    {
        [self createRoute];
    }
    else
    {
        [self.navigationManager stop];
        if (![[NMAPositioningManager sharedPositioningManager].dataSource isKindOfClass:[NMADevicePositionSource class]]) {
            [NMAPositioningManager sharedPositioningManager].dataSource = nil;
        }
        // Restore the map orientation to show entire route on screen
        [self.mapView setBoundingBox:self.geoBoundingBox withAnimation:NMAMapAnimationLinear];
        [self.mapView setOrientation:0];
        [self setMapTrackingEnabled:NO];
        [self.navigationControlButton setTitle:@"Start Navigation" forState:UIControlStateNormal];
        self.route = nil;
        [self.mapView removeMapObject:self.mapRoute];
        self.mapRoute = nil;
        self.geoBoundingBox = nil;
    }
}

#pragma mark - Route creation and navigation code

- (void)createRoute
{
    // Create an NSMutableArray to add two stops
    NSMutableArray* stops = [[NSMutableArray alloc] initWithCapacity:2];

    // The navigation reroute callbacks are triggered when there is divergence between the
    // navigation route and user actual route. To achieve this situation:
    // 1) the `Navigation` (not `Simulation`) mode should be used,
    // 2) the route below should be configured using own route coordinates
    // 3) during navigation user should move other route than the navigation route.

    // START: 4350 Still Creek Dr
    NMAGeoCoordinates* hereBurnaby =
        [[NMAGeoCoordinates alloc] initWithLatitude:49.259149 longitude:-123.008555];
    // END: Langley BC
    NMAGeoCoordinates* langley =
        [[NMAGeoCoordinates alloc] initWithLatitude:49.0736 longitude:-122.559549];
    [stops addObject:hereBurnaby];
    [stops addObject:langley];

    // Create an NMARoutingMode, then set it to find the fastest car route without going
    // on Highway.
    NMARoutingMode* routingMode =
        [[NMARoutingMode alloc] initWithRoutingType:NMARoutingTypeFastest
                                      transportMode:NMATransportModeCar
                                     routingOptions:NMARoutingOptionAvoidHighway];

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
                        if ( routeResult && routeResult.routes.count >= 1 ) {
                            // Let's add the 1st result onto the map
                            strongSelf.route = routeResult.routes[0];
                            [strongSelf updateMapRouteWithRoute:strongSelf.route];
                            // initiate the navigation
                            [strongSelf startNavigation];
                        } else {
                            [strongSelf showMessage:@"Error:route result returned is not valid"];
                        }
                    } else {
                        [strongSelf showMessage:[NSString stringWithFormat:@"Error:route calculation returned error code %d",
                                           (int)error]];
                    }
                }];
}

- (void)startNavigation
{
    [self.navigationControlButton setTitle:@"Stop Navigation" forState:UIControlStateNormal];
    // Display the position indicator on map
    self.mapView.positionIndicator.visible = YES;
    // Configure NavigationManager to launch navigation on current map
    [self.navigationManager setMap:self.mapView];

    // Avoid retain cycle of self object
    __weak __typeof__(self) weakSelf = self;
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Choose Navigation mode"
                                 message:@"Please choose a mode"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons

    UIAlertAction* deviceButton = [UIAlertAction
                                   actionWithTitle:@"Navigation"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        // make strong self object for method calls in block
        __typeof__(self) strongSelf = weakSelf;
        // Start the turn-by-turn navigation. Please note if the transport mode of the passed-in
        // route is pedestrian, the NavigationManager automatically triggers the guidance which is
        // suitable for walking.
        [strongSelf startTurnByTurnNavigationWithRoute:strongSelf.route useSimulation:NO];
    }];
    UIAlertAction* simulateButton = [UIAlertAction
                                     actionWithTitle:@"Simulation"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
        // make strong self object for method calls in block
        __typeof__(self) strongSelf = weakSelf;
        [strongSelf startTurnByTurnNavigationWithRoute:strongSelf.route useSimulation:YES];
    }];

    [alert addAction:deviceButton];
    [alert addAction:simulateButton];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startTurnByTurnNavigationWithRoute:(NMARoute *)route useSimulation:(BOOL)shouldSimulate
{
    NSError *error = [self.navigationManager startTurnByTurnNavigationWithRoute:route];
    if (!error) {
        // Set the map tracking properties
        [self setMapTrackingEnabled:YES];
        if (shouldSimulate) {
            // Simulation navigation by init the PositionSource with route and set movement speed
            NMARoutePositionSource *source = [[NMARoutePositionSource alloc] initWithRoute:route];
            source.movementSpeed = 60;
            [NMAPositioningManager sharedPositioningManager].dataSource = source;
        }
    } else {
        [self showMessage:[NSString stringWithFormat:
                           @"Error:start navigation returned error code %ld", (long)error.code]];
    }
}

- (void)setMapTrackingEnabled:(BOOL)enabled
{
    self.navigationManager.mapTrackingEnabled = enabled;
    self.navigationManager.mapTrackingAutoZoomEnabled = enabled;
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
        self.geoBoundingBox = route.boundingBox;
        [self.mapView setBoundingBox:route.boundingBox
                       withAnimation:NMAMapAnimationLinear];
    }
}

#pragma mark - NMANavigationManagerDelegate methods

- (void)navigationManagerWillReroute:(NMANavigationManager *)navigationManager
{
    [self showMessage:@"New navigation route will be created"];
}


- (void)navigationManager:(NMANavigationManager *)navigationManager
 didUpdateRouteWithResult:(NMARouteResult *)routeResult
{
    if ( routeResult && routeResult.routes.count >= 1 )
    {
        // Let's add the 1st result onto the map
        self.route = routeResult.routes[0];
        [self updateMapRouteWithRoute:self.route];
    }
    else
    {
        // The routeResult doesn't contain route for redraw.
        // It might occur when navigation stop was called.
    }
}

- (void)navigationManager:(NMANavigationManager *)navigationManager
      didRerouteWithError:(NMARoutingError)error
{
    NSString *message = nil;
    if (error != NMARoutingErrorNone) {
        message = @"successfully";
    } else {
        message = [NSString stringWithFormat:@"with error %lu", (unsigned long)error];
    }
    [self showMessage:[NSString stringWithFormat:@"Navigation manager finished attempt to route %@",
                       message]];
}

// Signifies that there is new instruction information available
- (void)navigationManager:(NMANavigationManager*)navigationManager
       hasCurrentManeuver:(NMAManeuver*)maneuver
             nextManeuver:(NMAManeuver*)nextManeuver
{
    [self showMessage:@"New maneuver is available"];
}

// Signifies that the system has found a GPS signal
- (void)navigationManagerDidFindPosition:(NMANavigationManager*)navigationManager
{
    [self showMessage:@"New position has been found"];
}

#pragma mark - UI utility

- (void)showMessage:(NSString*)message
{
    CGRect frame = CGRectMake( 110, 200, 220, 120 );

    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor groupTableViewBackgroundColor];
    label.textColor = [UIColor blueColor];
    label.text = message;
    label.numberOfLines = 0;

    CGRect rect = [[label text]
        boundingRectWithSize:frame.size
                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                  attributes:@{
                      NSFontAttributeName : label.font
                  }
                     context:nil];
    frame.size = rect.size;
    label.frame = frame;

    [self.view addSubview:label];

    [UIView animateWithDuration:3.0
        animations:^{
          label.alpha = 0;
        }
        completion:^( BOOL finished ) {
          [label removeFromSuperview];
        }];
}

@end
