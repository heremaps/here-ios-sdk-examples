/*
 * Copyright (c) 2016-2021 HERE Europe B.V.
 * All rights reserved.
 */

#import <NMAKit/NMAKit.h>

#import "MainViewController.h"
#import "FcwTableViewCell.h"

@interface MainViewController ()

@property (strong, nonatomic) IBOutlet NMAMapView *mapView;
@property (strong, nonatomic) NMAVenue3dVenue *selectedVenue;
@property (strong, nonatomic) NMAVenue3dMapLayer* venueMapLayer;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UITableView *floorChangeWidget;
@property (strong, nonatomic) NSMutableArray *venueLevelObjects;
@property (strong, nonatomic) NMAGeoCoordinates *lastKnownCoordinate;
@property int lastKnownFloorId;
@property (strong, nonatomic) NSString *lastKnownBuildingId;
@property (strong, nonatomic) NMAVenue3dRoutingController *routingController;
@property (strong, nonatomic) NMAVenue3dSpace *selectedSpace;
@property BOOL routeVisible;
@property (weak, nonatomic) IBOutlet UIButton *showRouteButton;
@property BOOL mapCentered;

@end

@interface FcwObject : NSObject

@property NSInteger floorNumber;
@property (strong, nonatomic) NSString* floorSynonym;
@property BOOL isGroundFloor;

@end

@implementation FcwObject

@synthesize floorNumber;
@synthesize floorSynonym;
@synthesize isGroundFloor;

@end

@implementation NSMutableArray (Reverse)

- (void)reverseArray {
    NSInteger i = 0;
    NSInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        i++;
        j--;
    }
}

@end

@implementation MainViewController

static int UNKNOWN_FLOOR_ID = -999;

@synthesize selectedVenue;
@synthesize venueMapLayer;
@synthesize floorChangeWidget;
@synthesize venueLevelObjects;
@synthesize lastKnownCoordinate;
@synthesize lastKnownBuildingId;
@synthesize lastKnownFloorId;
@synthesize routingController;
@synthesize selectedSpace;
@synthesize routeVisible;
@synthesize showRouteButton;
@synthesize mapCentered;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Change data source to HERE position data source
    NMAPositioningManager.sharedPositioningManager.dataSource = [[NMAHEREPositionSource alloc] init];

    // Set initial position
    NMAGeoCoordinates *geoCoordCenter = [[NMAGeoCoordinates alloc] initWithLatitude:61.494713 longitude:23.775360];
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    mapCentered = false;
    self.mapView.copyrightLogoPosition = NMALayoutPositionBottomCenter;

    // Set zoom level
    self.mapView.zoomLevel = NMAMapViewMaximumZoomLevel - 1;

    [[NMAVenue3dService sharedVenueService]setCombinedContent:TRUE];
    [[NMAVenue3dService sharedVenueService]setPrivateContent:TRUE];
    venueMapLayer = self.mapView.venue3dMapLayer;
    venueMapLayer.delegate = self;
    [venueMapLayer start];
    routingController = venueMapLayer.venueRoutingController;
    [routingController addObserver:self];

    // Subscribe to position updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePosition)
                                                 name:NMAPositioningManagerDidUpdatePositionNotification
                                               object:[NMAPositioningManager sharedPositioningManager]];

    // Set position indicator visible. Also starts position updates.
    self.mapView.positionIndicator.visible = YES;

    // Create floor change widget
    venueLevelObjects = [[NSMutableArray alloc]init];
    floorChangeWidget.dataSource = self;
    UINib *cellNib = [UINib nibWithNibName:@"FcwTableViewCell" bundle:[NSBundle mainBundle]];
    [floorChangeWidget registerNib:cellNib forCellReuseIdentifier:@"FcwTableViewCell"];
    floorChangeWidget.separatorInset = UIEdgeInsetsZero;
    floorChangeWidget.layoutMargins = UIEdgeInsetsZero;
    [floorChangeWidget setShowsHorizontalScrollIndicator:NO];
    [floorChangeWidget setShowsVerticalScrollIndicator:NO];
    [floorChangeWidget setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    floorChangeWidget.hidden = YES;
    floorChangeWidget.delegate = self;

    showRouteButton.hidden = YES;
}

- (void)didUpdatePosition {
    NMAGeoPosition *position = [[NMAPositioningManager sharedPositioningManager] currentPosition];
    lastKnownCoordinate = position.coordinates;

    if (position.source == NMAGeoPositionSourceIndoor) {
        lastKnownFloorId = [position.floorId intValue];
        lastKnownBuildingId = position.buildingId;
    } else {
        lastKnownFloorId = UNKNOWN_FLOOR_ID;
        lastKnownBuildingId = @"";
    }

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

    if (!mapCentered && position.isValid) {
        // Update map center to initial valid position
        [_mapView setGeoCenter:position.coordinates
                 withAnimation:NMAMapAnimationLinear];
        mapCentered = true;
    }
}

-(void)showOrHideFcw
{
    if (selectedVenue != nil) {
        NSArray<NMAVenue3dLevel *> *levels = selectedVenue.levels;
        [venueLevelObjects removeAllObjects];
        for (NMAVenue3dLevel* level in levels) {
            FcwObject *obj = [[FcwObject alloc]init];
            obj.floorSynonym = level.floorSynonym;
            obj.floorNumber = level.floorNumber;
            if (level.floorNumber == 0) {
                obj.isGroundFloor = TRUE;
            } else {
                obj.isGroundFloor = FALSE;
            }
            [venueLevelObjects addObject:obj];
        }
        [venueLevelObjects reverseArray];
        [floorChangeWidget reloadData];
        [floorChangeWidget sizeToFit];
        floorChangeWidget.hidden = NO;
        [self updateFloorChangeWidget:UNKNOWN_FLOOR_ID];
    } else {
        floorChangeWidget.hidden = YES;
    }
}

-(void)updateFloorChangeWidget:(double)oldFloorNumber
{
    if (selectedVenue != nil) {
        NSInteger currentNumber = selectedVenue.floorNumber;
        for (int i=0; i < venueLevelObjects.count ; i++) {
            FcwObject *obj = [venueLevelObjects objectAtIndex:i];
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            if (obj.floorNumber == currentNumber) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
                [floorChangeWidget selectRowAtIndexPath:path animated:TRUE scrollPosition:UITableViewScrollPositionMiddle];
                FcwTableViewCell* cell = [floorChangeWidget cellForRowAtIndexPath:path];
                cell.floorName.textColor = [UIColor whiteColor];
            } else if (obj.floorNumber == oldFloorNumber) {
                FcwTableViewCell* cell = [floorChangeWidget cellForRowAtIndexPath:path];
                cell.floorName.textColor = [UIColor blackColor];
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [venueLevelObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FcwTableViewCell";
    FcwTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[FcwTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    FcwObject *obj = [venueLevelObjects objectAtIndex:indexPath.row];
    cell.floorName.text = obj.floorSynonym;
    [cell setLayoutMargins:UIEdgeInsetsZero];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor blackColor];
    [cell setSelectedBackgroundView:bgColorView];
    cell.floorName.textColor = [UIColor blackColor];
    if (obj.isGroundFloor) {
        [cell.groundFloorIndicator setHidden:NO];
    } else {
        [cell.groundFloorIndicator setHidden:YES];
    }
    NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
    if (indexPath == selectedIndexPath) {
        cell.floorName.textColor = [UIColor whiteColor];
    } else {
        cell.floorName.textColor = [UIColor blackColor];
    }
    if (selectedVenue != nil && [selectedVenue.uniqueId isEqualToString:lastKnownBuildingId]) {
        // Selected venue matches last known building
        if (self.lastKnownFloorId != UNKNOWN_FLOOR_ID) {
            if (self.lastKnownFloorId == obj.floorNumber) {
                [cell.currentFloorIndicator setHidden:NO];
            } else {
                [cell.currentFloorIndicator setHidden:YES];
            }
        } else {
            [cell.currentFloorIndicator setHidden:YES];
        }
    } else {
        [cell.currentFloorIndicator setHidden:YES];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedVenue != nil) {
        FcwObject *obj = [venueLevelObjects objectAtIndex:indexPath.row];
        NSInteger selectedLevel = obj.floorNumber;
        NMAVenue3dController *venueController = venueMapLayer.venueController;
        if (venueController != nil) {
            NSArray *levels = selectedVenue.levels;
            for (NMAVenue3dLevel* level in levels) {
                if (level.floorNumber == selectedLevel) {
                    [venueController setLevel:level];
                    break;
                }
            }
        }
        FcwTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.floorName.textColor = [UIColor whiteColor];
        if (obj.isGroundFloor) {
            [cell.groundFloorIndicator setHidden:NO];
        } else {
            [cell.groundFloorIndicator setHidden:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedVenue != nil) {
        FcwObject *obj = [venueLevelObjects objectAtIndex:indexPath.row];
        FcwTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.floorName.textColor = [UIColor blackColor];
        if (obj.isGroundFloor) {
            [cell.groundFloorIndicator setHidden:NO];
        } else {
            [cell.groundFloorIndicator setHidden:YES];
        }
    }
}

- (void)venueMapLayer:(NMAVenue3dMapLayer *)venueMapLayer didTapVenue:(NMAVenue3dVenue *)venue atPoint:(CGPoint)point
{
    [venueMapLayer selectVenue:venue];
}

- (void)venueMapLayer:(nonnull NMAVenue3dMapLayer *)venueMapLayer
       didSelectVenue:(nonnull NMAVenue3dVenue *)venue
{
    selectedVenue = venue;
    if ([selectedVenue.uniqueId isEqualToString:lastKnownBuildingId]) {
        NSArray<NMAVenue3dLevel *> *selectedLevels = selectedVenue.levels;
        for (NMAVenue3dLevel *level in selectedLevels) {
            if (level.floorNumber == self.lastKnownFloorId) {
                NMAVenue3dController *venueController = venueMapLayer.venueController;
                [venueController setLevel:level];
                break;
            }
        }
    }
    [self showOrHideFcw];
}

- (void)venueMapLayer:(nonnull NMAVenue3dMapLayer *)venueMapLayer
       didSelectSpace:(nonnull NMAVenue3dSpace *)space
              inVenue:(nonnull NMAVenue3dVenue *)venue
{
    showRouteButton.hidden = NO;
    selectedSpace = space;
}

- (void)venueMapLayer:(nonnull NMAVenue3dMapLayer *)venueMapLayer
     didDeselectSpace:(nonnull NMAVenue3dSpace *)space
              inVenue:(nonnull NMAVenue3dVenue *)venue
{
    showRouteButton.hidden = YES;
    if (routeVisible) {
        // Hide previous route if still visible
        [venueMapLayer.venueRoutingController hideRoute];
        routeVisible = false;
    }
    selectedSpace = nil;
}

- (void)venueMapLayer:(nonnull NMAVenue3dMapLayer *)venueMapLayer
     didDeselectVenue:(nonnull NMAVenue3dVenue *)venue
            withEvent:(NMAVenue3dDeselectEvent)event
{
    selectedVenue = nil;
    selectedSpace = nil;
    showRouteButton.hidden = YES;
    if (routeVisible) {
        // Hide previous route if still visible
        [venueMapLayer.venueRoutingController hideRoute];
        routeVisible = false;
    }
    [self showOrHideFcw];
}

- (void)showRouteToVenue:(NMAVenue3dVenue*)venue latitude:(double)latitude longitude:(double)longitude floorId:(double)floorId {
    [venueMapLayer.venueRoutingController hideRoute];
    routeVisible = false;
    if (lastKnownCoordinate == nil) {
        return;
    }

    NMARoutingMode *routingMode;
    routingMode = [[NMARoutingMode alloc] initWithRoutingType:NMARoutingTypeShortest
                                                transportMode:NMATransportModePedestrian
                                               routingOptions:0];
    NMAVenue3dRouteOptions *routeOptions =
    [NMAVenue3dRouteOptions optionsWithRoutingMode:routingMode];
    [routeOptions setAvoidStairs:false];
    [routeOptions setAvoidRamps:false];
    [routeOptions setPreferCorridors:true];
    [routeOptions setAvoidElevators:false];
    [routeOptions setPreferGroundEntrances:true];

    NMAVenue3dController *targetVenueController =  [venueMapLayer controllerForVenue:venue];
    NMAGeoCoordinates *endPosition =
    [NMAGeoCoordinates geoCoordinatesWithLatitude:latitude longitude:longitude];
    NMAGeoCoordinates *startPosition =
    [NMAGeoCoordinates geoCoordinatesWithLatitude:lastKnownCoordinate.latitude longitude:lastKnownCoordinate.longitude];

    if (lastKnownFloorId != UNKNOWN_FLOOR_ID && ![lastKnownBuildingId isEqualToString:@""] &&
        selectedVenue != nil && [selectedVenue.uniqueId isEqualToString:lastKnownBuildingId]) {
        NMAVenue3dController *selectedVenueController = [venueMapLayer controllerForVenue:selectedVenue];
        NMAVenue3dLevel *startLevel = nil;
        NSArray<NMAVenue3dLevel *> *startLevels = selectedVenue.levels;
        for (NMAVenue3dLevel *level in startLevels) {
            double levelFloorNumber = level.floorNumber;
            if (levelFloorNumber == lastKnownFloorId) {
                startLevel = level;
                break;
            }
        }
        NMAVenue3dLevelLocation *startLocation = [[NMAVenue3dLevelLocation alloc]initOnLevel:startLevel withGeoCoordinate:startPosition inVenue:selectedVenueController];
        NSArray<NMAVenue3dLevel *> *endLevels = selectedVenue.levels;
        NMAVenue3dLevel *endLevel = nil;
        for (NMAVenue3dLevel *level in endLevels) {
            double levelFloorNumber = level.floorNumber;
            if (levelFloorNumber == floorId) {
                endLevel = level;
                break;
            }
        }
        NMAVenue3dLevelLocation *endLocation = [[NMAVenue3dLevelLocation alloc]initOnLevel:endLevel withGeoCoordinate:endPosition inVenue:targetVenueController];
        [routingController calculateRouteFrom:startLocation to:endLocation
                                    withParams:routeOptions];
    } else {
        NMAVenue3dOutdoorLocation *startLocation =
        [NMAVenue3dOutdoorLocation outdoorLocationWithGeoCoordinates:startPosition];
        NSArray<NMAVenue3dLevel *> *levels = selectedVenue.levels;
        NMAVenue3dLevel *endLevel = nil;
        for (NMAVenue3dLevel *level in levels) {
            double levelFloorNumber = level.floorNumber;
            if (levelFloorNumber == floorId) {
                endLevel = level;
                break;
            }
        }
        NMAVenue3dLevelLocation *endLocation = [[NMAVenue3dLevelLocation alloc]initOnLevel:endLevel withGeoCoordinate:endPosition inVenue:targetVenueController];
        [routingController calculateRouteFrom:startLocation to:endLocation
                                    withParams:routeOptions];
    }
}

- (void)didCalculateRoute:(nonnull NMAVenue3dCombinedRoute *)combinedRoute
{
    NMAVenue3dRoutingError error = combinedRoute.getError;
    if (error == NMAVenue3dRoutingErrorNoError) {
        if (routeVisible) {
            // Hide previous route if still visible
            [venueMapLayer.venueRoutingController hideRoute];
        }
        [venueMapLayer.venueRoutingController showRoute: combinedRoute];
        routeVisible = true;
    }
}

- (IBAction)showRouteButtonPressed:(id)sender {
    if (selectedVenue != nil && selectedSpace != nil) {
        double lat = selectedSpace.geoCenter.latitude;
        double lon = selectedSpace.geoCenter.longitude;
        double floorId = selectedSpace.floorNumber;
        [self showRouteToVenue:selectedVenue latitude:lat longitude:lon floorId:floorId];
    }
}

@end
