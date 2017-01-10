/*
 * Copyright © 2011-2016 HERE Global B.V. and its affiliate(s).
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */
#import "MapViewController.h"


@interface MapViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView* mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* segmentedCtrl;

@end

@implementation MapViewController {

    NMAMapPolygon* _geoPolygon;
    NMAMapPolyline* _geoPolyline;
    NMAGeoBoundingBox* _geoBox;
    NMAGeoCoordinates* _geoCoord;
    NMAMapMarker* _mapMarker;
    NMAMapCircle* _mapCircle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //create geo coordinate
    _geoCoord = [[NMAGeoCoordinates alloc] initWithLatitude:52.500556 longitude:13.398889];
    // set map view with geo center
    [self.mapView setGeoCenter:_geoCoord];
}


/**
 * remove map objects which were added to current active map view.
 */
-(void) cleanup {
    //if NMAMapPolygon map object alreasy exists, remove it from map view.
    if (_geoPolygon) {
        [self.mapView removeMapObject:_geoPolygon];
        _geoPolygon = nil;
    }
    //if NMAMapPolyline map object alreasy exists, remove it from map view.
    if( _geoPolyline) {
        [self.mapView removeMapObject:_geoPolyline];
        _geoPolyline = nil;
    }
    //if NMAMapMarker map object alreasy exists, remove it from map view.
    if( _mapMarker) {
        [self.mapView removeMapObject:_mapMarker];
        _mapMarker = nil;
    }
    //if NMAMapCircle map object alreasy exists, remove it from map view.
    if(_mapCircle) {
        [self.mapView removeMapObject:_mapCircle];
        _mapCircle = nil;
    }
}

/**
 * create a NMAMapPolygon object, then add it to current active map view.
 */
- (void)createPolygon {

    [self cleanup];

    if (_geoPolygon == nil) {
        //create a NMAGeoBoundingBox with center gec coordinates, width and hegiht in degrees.
        _geoBox = [NMAGeoBoundingBox geoBoundingBoxWithCenter:_geoCoord width:0.01 height:0.01];
        //create a NMAGeoPolygon with bounding box's vertices.
        _geoPolygon = [NMAMapPolygon mapPolygonWithVertices:@[_geoBox.topLeft,_geoBox.bottomLeft,_geoBox.bottomRight,_geoBox.topRight]];
        //set fill color to be gray
        _geoPolygon.fillColor = [UIColor grayColor];
        //set border line width in pixels
        _geoPolygon.lineWidth = 12;
        //set line color to be red
        _geoPolygon.lineColor = [UIColor redColor];
        //add this NMAMapPolygon to map view
        [self.mapView addMapObject:_geoPolygon];
    }
}

/**
 * create a NMAMapPolyline object, then add it to current active map view.
 */
- (void) createPolyline {
    [self cleanup];

    if (_geoPolyline == nil) {
        //create a NMAGeoBoundingBox with center gec coordinates, width and hegiht in degrees.
        _geoBox = [NMAGeoBoundingBox geoBoundingBoxWithCenter:_geoCoord width:0.01 height:0.01];
        //create a NMAGeoPolyline with bounding box's vertices.
        _geoPolyline = [NMAMapPolyline mapPolylineWithVertices:@[_geoBox.topLeft,_geoBox.bottomLeft,_geoBox.bottomRight,_geoBox.topRight,_geoBox.topLeft]];
        //set border line width in pixels
        _geoPolyline.lineWidth = 12;
        //set border line color to be red
        _geoPolyline.lineColor = [UIColor redColor];
        //add NMAMapPolyline to map view
        [self.mapView addMapObject:_geoPolyline];
    }
}

/**
 * create a NMAMapMarker object, then add it to current active map view.
 */
- (void)createMapMarker {
    [self cleanup];
    if (_mapMarker == nil) {
        //create NMAImage with local cafe.png
        NMAImage* markerImage = [NMAImage imageWithUIImage:[UIImage imageNamed:@"cafe.png"]];
        //create NMAMapMarker located with geo coordinate and icon image
        _mapMarker = [NMAMapMarker mapMarkerWithGeoCoordinates:_geoCoord icon:markerImage];
        //add NMAMapMarker to map view
        [self.mapView addMapObject:_mapMarker];
    }
}

/**
 * create a NMAMapCircel object, then add it to current active map view.
 */
- (void)createCircle {
    [self cleanup];
    if (_mapCircle == nil) {
        //create NMAMapCircle located at geo coordiate and with radium in meters
        _mapCircle = [NMAMapCircle mapCircleWithGeoCoordinates:_geoCoord radius:250.0];
        //set fill color to be gray
        _mapCircle.fillColor = [UIColor grayColor];
        //set border line width.
        _mapCircle.lineWidth = 12;
        //set border line color to be red.
        _mapCircle.lineColor = [UIColor redColor];
        //add Map Circel to map view
        [self.mapView addMapObject:_mapCircle];
    }
}

/**
 * create an appropriate map object when clicking segment control
 */
- (IBAction)segmentedCtrlPressed:(id)sender {
    switch (_segmentedCtrl.selectedSegmentIndex) {
        case 0:
            //create NMAMapPolygon
            [self createPolygon];
            break;
        case 1:
            //create NMAMapPolyline
            [self createPolyline];
            break;
        case 2:
            //create NMAMapCircle
            [self createCircle];
            break;
        case 3:
            //create NMAMapMarker
            [self createMapMarker];
            break;
        default:
            break;
    }
}
@end
