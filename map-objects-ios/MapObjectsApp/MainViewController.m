/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
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
