/*
 * Copyright (c) 2011-2021 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import <math.h>

typedef NS_ENUM(NSUInteger, MapObjectOption) {
    MapObjectOptionPolygon = 0,
    MapObjectOptionPolyline,
    MapObjectOptionMapMarker,
    MapObjectOptionMapCircle,
};

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView* mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* segmentedCtrl;

// Used for displaying the coordinates of draggable marker
@property (strong, nonatomic) UIView *coordinatesUpdateView;
@property (strong, nonatomic) UILabel *coordinatesLabel;

// Identifiers for MapMarker event handlers
@property (nonatomic) NSInteger mapMarkerMoveBeganEventHandlerId;
@property (nonatomic) NSInteger mapMarkerMoveEndedEventHandlerId;
@property (nonatomic) NSInteger mapMarkerMovedEventHandlerId;

@end

@implementation MainViewController {
    NSMutableArray<NMAMapPolygon*>* _geoPolygons;
    NSMutableArray<NMAMapPolyline*>* _geoPolylines;
    NSMutableArray<NMAMapMarker*>* _mapMarkers;
    NSMutableArray<NMAMapCircle*>* _mapCircles;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //create geo coordinate
    _geoPolygons = [NSMutableArray array];
    _geoPolylines = [NSMutableArray array];
    _mapMarkers = [NSMutableArray array];
    _mapCircles = [NSMutableArray array];

    // set map view with geo center
    [self.mapView setGeoCenter:[[NMAGeoCoordinates alloc] initWithLatitude:52.500556 longitude:13.398889]];
}

- (void)setupCoordinatesView
{
    CGFloat kCoordinatesViewHeight = 120.0f;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, kCoordinatesViewHeight);
    [self createCoordinatesUpdateViewWithFrame:frame];
    [self createCoordinatesLabelWithFrame:frame];
}

-(void)createCoordinatesUpdateViewWithFrame:(CGRect)frame
{
    _coordinatesUpdateView = [[UIView alloc] initWithFrame:frame];
    _coordinatesUpdateView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_coordinatesUpdateView];

    _coordinatesUpdateView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *coordinatesUpdateViewBindings = @{ @"_coordinatesUpdateView" : _coordinatesUpdateView };
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_coordinatesUpdateView]-(0)-|"
                                             options:0 metrics:nil
                                               views:coordinatesUpdateViewBindings]];
    NSString *updateViewVFCV = [NSString stringWithFormat:@"V:|-(>=0)-[_coordinatesUpdateView(%f)]-(0)-|",
                                           frame.size.height];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:updateViewVFCV
                                             options:0 metrics:nil
                                               views:coordinatesUpdateViewBindings]];
}

-(void)createCoordinatesLabelWithFrame:(CGRect)frame
{
    _coordinatesLabel = [[UILabel alloc] initWithFrame:frame];
    _coordinatesLabel.numberOfLines = 0;
    _coordinatesLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _coordinatesLabel.text = @"Make long press gesture on MapMarker to start dragging, "
    "then move finger to move marker to desired position.";
    [_coordinatesUpdateView addSubview:_coordinatesLabel];

    _coordinatesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *coordinatesLabelBindings = @{ @"_coordinatesLabel" : _coordinatesLabel };
    [_coordinatesUpdateView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_coordinatesLabel]-(0)-|"
                                             options:0 metrics:nil views:coordinatesLabelBindings]];
    [_coordinatesUpdateView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[_coordinatesLabel]-(0)-|"
                                             options:0 metrics:nil views:coordinatesLabelBindings]];
}

/**
 * create a NMAMapPolygon object, then add it to current active map view.
 */
- (void)addPolygon {

    //create a NMAGeoBoundingBox with center gec coordinates, width and hegiht in degrees.
    NMAGeoBoundingBox* geoBox = [NMAGeoBoundingBox geoBoundingBoxWithCenter:self.mapView.geoCenter width:0.01 height:0.01];
    //create a NMAGeoPolygon with bounding box's vertices.
    NMAMapPolygon* geoPolygon = [NMAMapPolygon mapPolygonWithVertices:@[geoBox.topLeft, geoBox.bottomLeft, geoBox.bottomRight, geoBox.topRight]];
    //set fill color to be gray
    geoPolygon.fillColor = [UIColor grayColor];
    //set border line width in pixels
    geoPolygon.lineWidth = 12;
    //set line color to be red
    geoPolygon.lineColor = [UIColor redColor];
    //add this NMAMapPolygon to map view
    [self.mapView addMapObject:geoPolygon];

    [_geoPolygons addObject:geoPolygon];
}

/**
 * create a NMAMapPolyline object, then add it to current active map view.
 */
- (void) addPolyline {
    NMAGeoBoundingBox* geoBox = [NMAGeoBoundingBox geoBoundingBoxWithCenter:self.mapView.geoCenter width:0.01 height:0.01];
    //create a NMAGeoPolyline with bounding box's vertices.
    NMAMapPolyline* geoPolyline = [NMAMapPolyline mapPolylineWithVertices:@[geoBox.topLeft, geoBox.bottomLeft, geoBox.bottomRight, geoBox.topRight, geoBox.topLeft]];
    //set border line width in pixels
    geoPolyline.lineWidth = 12;
    //set border line color to be red
    geoPolyline.lineColor = [UIColor redColor];
    //add NMAMapPolyline to map view
    [self.mapView addMapObject:geoPolyline];

    [_geoPolylines addObject:geoPolyline];
}

/**
 * create a NMAMapMarker object, then add it to current active map view.
 */
- (void)addMapMarker {
    //create NMAImage with local cafe.png
    NMAImage* markerImage = [NMAImage imageWithUIImage:[UIImage imageNamed:@"cafe.png"]];
    //create NMAMapMarker located with geo coordinate and icon image
    NMAMapMarker* mapMarker = [NMAMapMarker mapMarkerWithGeoCoordinates:self.mapView.geoCenter icon:markerImage];
    //make marker able to receive dragging gesture from map
    mapMarker.draggable = YES;
    //add NMAMapMarker to map view
    [self.mapView addMapObject:mapMarker];
    //add view and handlers for *MarkerDrag* events:
    [self setupMapMarkerEventHandlersIfNeeded];

    [_mapMarkers addObject:mapMarker];
}

/**
 * Add view and handlers when first mapMarker is added.
 */
-(void)setupMapMarkerEventHandlersIfNeeded
{
    if ( ![_mapMarkers count] ) {
        [self setupCoordinatesView];
        [self setupMapMarkerEventHandlers];
    }
}

/**
 * Remove view and handlers when last mapMarker is removed.
 */
-(void)removeMapMarkerEventHandlersIfNeeded
{
    if ( ![_mapMarkers count] ) {
        [self removeCoordinatesView];
        [self removeMapMarkerEventHandlers];
    }
}

/**
 * Add handlers for map events:
 * - NMAMapEventMarkerDragBegan,
 * - NMAMapEventMarkerDragged,
 * - NMAMapEventMarkerDragEnded.
 */
-(void)setupMapMarkerEventHandlers
{
    self.mapMarkerMoveBeganEventHandlerId = [self.mapView respondToEvents:NMAMapEventMarkerDragBegan
                                                                withBlock:^BOOL(NMAMapEvent event,
                                                                                NMAMapView *mapView,
                                                                                NMAMapMarker *eventData)
                                             {
                                                 [self updateLabelWithCoordinates:eventData.coordinates
                                                                        fromEvent:@"NMAMapEventMarkerDragBegan"];
                                                 return YES;
                                             }];

    self.mapMarkerMoveEndedEventHandlerId = [self.mapView respondToEvents:NMAMapEventMarkerDragEnded
                                                                withBlock:^BOOL(NMAMapEvent event,
                                                                                NMAMapView *mapView,
                                                                                NMAMapMarker *eventData)
                                             {
                                                 [self updateLabelWithCoordinates:eventData.coordinates
                                                                        fromEvent:@"NMAMapEventMarkerDragEnded"];
                                                 return YES;
                                             }];

    self.mapMarkerMovedEventHandlerId = [self.mapView respondToEvents:NMAMapEventMarkerDragged
                                                            withBlock:^BOOL(NMAMapEvent event,
                                                                            NMAMapView *mapView,
                                                                            NMAMapMarker *eventData)
                                         {
                                             [self updateLabelWithCoordinates:eventData.coordinates
                                                                    fromEvent:@"NMAMapEventMarkerDragged"];
                                             return YES;
                                         }];
}

-(void)removeCoordinatesView
{
    [_coordinatesUpdateView removeFromSuperview];
    _coordinatesUpdateView = nil;
    _coordinatesLabel = nil;
}

/**
 * Remove handlers for map events:
 * - NMAMapEventMarkerDragBegan,
 * - NMAMapEventMarkerDragged,
 * - NMAMapEventMarkerDragEnded.
 */
-(void)removeMapMarkerEventHandlers
{
    [self.mapView removeEventBlockWithIdentifier:self.mapMarkerMoveBeganEventHandlerId];
    [self.mapView removeEventBlockWithIdentifier:self.mapMarkerMovedEventHandlerId];
    [self.mapView removeEventBlockWithIdentifier:self.mapMarkerMoveEndedEventHandlerId];
}

/**
 * Visualize the coordinates during the mapMarker drag event.
 * Only last dragged mapMarker event data is displayed.
 */
-(void)updateLabelWithCoordinates:(NMAGeoCoordinates *)coordinates
                        fromEvent:(NSString *)eventType
{
    NSString *text = [NSString stringWithFormat:@"%@ :\n <latitude:%f, longitude: %f>", eventType,
                      coordinates.latitude, coordinates.longitude];
    NSLog(@"%@", text);
    _coordinatesLabel.text = text;
}

/**
 * create a NMAMapCircel object, then add it to current active map view.
 */
- (void)addCircle {
    //create NMAMapCircle located at geo coordiate and with radium in meters
    NMAMapCircle* mapCircle = [NMAMapCircle mapCircleWithGeoCoordinates:self.mapView.geoCenter radius:250.0];
    //set fill color to be gray
    mapCircle.fillColor = [UIColor grayColor];
    //set border line width.
    mapCircle.lineWidth = 12;
    //set border line color to be red.
    mapCircle.lineColor = [UIColor redColor];
    //add Map Circel to map view
    [self.mapView addMapObject:mapCircle];

    [_mapCircles addObject:mapCircle];
}

- (IBAction)onOptionButtonClicked:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [self addAddOptionToController:actionSheet optionId:MapObjectOptionPolygon title:@"Add polygon"];
    [self addRemoveOptionToCotroller:actionSheet optionsId:MapObjectOptionPolygon title:@"Remove polygon"];

    [self addAddOptionToController:actionSheet optionId:MapObjectOptionPolyline title:@"Add polyline"];
    [self addRemoveOptionToCotroller:actionSheet optionsId:MapObjectOptionPolyline title:@"Remove polyline"];

    [self addAddOptionToController:actionSheet optionId:MapObjectOptionMapCircle title:@"Add circle"];
    [self addRemoveOptionToCotroller:actionSheet optionsId:MapObjectOptionMapCircle title:@"Remove circle"];

    [self addAddOptionToController:actionSheet optionId:MapObjectOptionMapMarker title:@"Add marker"];
    [self addRemoveOptionToCotroller:actionSheet optionsId:MapObjectOptionMapMarker title:@"Remove marker"];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Navigate to markers" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self->_mapMarkers.count > 0) {
            [self navigateToMarkers];
        }
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIButton *optionButton = (UIButton *)sender;
        actionSheet.popoverPresentationController.sourceView = optionButton;
        actionSheet.popoverPresentationController.sourceRect = optionButton.bounds;
    }

    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)addAddOptionToController:(UIAlertController*)controller optionId:(int)optionId title:(NSString*)title {
    [controller addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        switch (optionId) {
            case MapObjectOptionPolygon:
                [self addPolygon];
                break;
            case MapObjectOptionPolyline:
                [self addPolyline];
                break;
            case MapObjectOptionMapMarker:
                [self addMapMarker];
                break;
            case MapObjectOptionMapCircle:
                [self addCircle];
                break;
            default:
                break;
        }
    }]];
}

- (void)addRemoveOptionToCotroller:(UIAlertController*)controller optionsId:(int)optionId title:(NSString*)title {
    [controller addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSMutableArray* array = [self getArrayForOptionId:optionId];
        NMAMapObject* lastAdded = [array lastObject];
        if (lastAdded) {
            [self.mapView removeMapObject:lastAdded];
            [array removeObject:lastAdded];
            if (MapObjectOptionMapMarker == optionId) {
                [self removeMapMarkerEventHandlersIfNeeded];
            }
        }
    }]];
}

- (NSMutableArray*) getArrayForOptionId:(int)optionId {
    switch (optionId) {
        default:
        case MapObjectOptionPolygon:
            return _geoPolygons;
        case MapObjectOptionPolyline:
            return _geoPolylines;
        case MapObjectOptionMapMarker:
            return _mapMarkers;
        case MapObjectOptionMapCircle:
            return _mapCircles;
    }
}

-(void)navigateToMarkers {
    // find max and min latitudes and longitudes in order to calculate
    // geo bounding box so then we can mapView->setBoundingBox(geoBox, ...) to it.
    double minLat = 90.0;
    double minLon = 180.0;
    double maxLat = -90.0;
    double maxLon = -180.0;

    for (NMAMapMarker* marker in _mapMarkers) {
        NMAGeoCoordinates* coordinate = marker.coordinates;

        double latitude = coordinate.latitude;
        double longitude = coordinate.longitude;

        minLat = fmin(minLat, latitude);
        minLon = fmin(minLon, longitude);
        maxLat = fmax(maxLat, latitude);
        maxLon = fmax(maxLon, longitude);
    }

    NMAGeoBoundingBox* box = [NMAGeoBoundingBox geoBoundingBoxWithTopLeft:[NMAGeoCoordinates geoCoordinatesWithLatitude:maxLat longitude:minLon]
                                                              bottomRight:[NMAGeoCoordinates geoCoordinatesWithLatitude:minLat longitude:maxLon]];
    CGFloat padding = 50;
    [[self mapView] setBoundingBox:box
                        insideRect:CGRectMake(padding, padding, self.mapView.bounds.size.width - padding * 2, self.mapView.bounds.size.height - padding * 2)
                     withAnimation:NMAMapAnimationLinear];
}

@end
