/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */
#import "MainViewController.h"
#import <math.h>

static const int OPTION_POLYGON = 0;
static const int OPTION_POLYLINE = 1;
static const int OPTION_MAP_MARKER = 2;
static const int OPTION_MAP_CIRCLE = 3;

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView* mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* segmentedCtrl;

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
    //add NMAMapMarker to map view
    [self.mapView addMapObject:mapMarker];

    [_mapMarkers addObject:mapMarker];
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
    [self addAddOptionToController:actionSheet optionId:OPTION_POLYGON title:@"Add polygon"];
    [self addRemoveOptionToCotroller:actionSheet optionsId:OPTION_POLYGON title:@"Remove polygon"];

    [self addAddOptionToController:actionSheet optionId:OPTION_POLYLINE title:@"Add polyline"];
    [self addRemoveOptionToCotroller:actionSheet optionsId:OPTION_POLYLINE title:@"Remove polyline"];

    [self addAddOptionToController:actionSheet optionId:OPTION_MAP_CIRCLE title:@"Add circle"];
    [self addRemoveOptionToCotroller:actionSheet optionsId:OPTION_MAP_CIRCLE title:@"Remove circle"];

    [self addAddOptionToController:actionSheet optionId:OPTION_MAP_MARKER title:@"Add marker"];
    [self addRemoveOptionToCotroller:actionSheet optionsId:OPTION_MAP_MARKER title:@"Remove marker"];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Navigate to markers" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self->_mapMarkers.count > 0) {
            [self navigateToMarkers];
        }
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];


    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)addAddOptionToController:(UIAlertController*)controller optionId:(int)optionId title:(NSString*)title {
    [controller addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        switch (optionId) {
            case OPTION_POLYGON:
                [self addPolygon];
                break;
            case OPTION_POLYLINE:
                [self addPolyline];
                break;
            case OPTION_MAP_MARKER:
                [self addMapMarker];
                break;
            case OPTION_MAP_CIRCLE:
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
        if (array.count > 0) {
            NMAMapObject* lastAdded = array[array.count - 1];
            [self.mapView removeMapObject:lastAdded];
            [array removeObject:lastAdded];
        }
    }]];
}

- (NSMutableArray*) getArrayForOptionId:(int)optionId {
    switch (optionId) {
        default:
        case OPTION_POLYGON:
            return _geoPolygons;
        case OPTION_POLYLINE:
            return _geoPolylines;
        case OPTION_MAP_MARKER:
            return _mapMarkers;
        case OPTION_MAP_CIRCLE:
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
