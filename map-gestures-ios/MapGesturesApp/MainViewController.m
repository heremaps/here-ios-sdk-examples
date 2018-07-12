/*
 * Copyright (c) 2011-2017 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet NMAMapView* mapView;
@end

@implementation MainViewController {
    NMAMapMarker* _gestureMarker;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    //set current controller to be delegate of map view's gesture
    self.mapView.gestureDelegate = self;

    //add image icon to show current positon, which can shows map view motion when gestures were applied
    UIImage* image = [UIImage imageNamed:@"indicator"];
    NMAMapMarker* indicatorMarker =
        [NMAMapMarker mapMarkerWithGeoCoordinates:[self.mapView geoCenter] image:image];
    [self.mapView addMapObject:indicatorMarker];
}

/**
 * callback when tap gesture occurred. It showed a image icon at location when tap gesture was applied.
 */
-(void)mapView:(NMAMapView *)mapView didReceiveTapAtLocation:(CGPoint)location
{
    // it showed a message label for tap gesture
    [self showMessage:@"Tap gesture"];

    //calculate geoCoordinates of tap gesture
    NMAGeoCoordinates *markerCoordinates = [self.mapView geoCoordinatesFromPoint:location];

    //it added a image icon to map view at location where tap gesture was applied.
    if(!_gestureMarker) {
        UIImage* image = [UIImage imageNamed:@"markerIcon"];
        _gestureMarker = [NMAMapMarker mapMarkerWithGeoCoordinates:markerCoordinates image:image];
        [_gestureMarker setAnchorOffsetUsingLayoutPosition:NMALayoutPositionBottomCenter];
        [self.mapView addMapObject:_gestureMarker];
    } else {
        _gestureMarker.coordinates = markerCoordinates;
    }
}

/**
 * callback when pan gesture occurred. It showed a message when pan gesture was applied.
 */

-(void)mapView:(NMAMapView *)mapView didReceivePan:(CGPoint)translation
                                        atLocation:(CGPoint)location
{
    [self showMessage:@"Pan gesture"];
}

/**
 * callback when totation gesture occurred. It showed a message when rotation gesture was applied.
 */
-(void)mapView:(NMAMapView *)mapView didReceiveRotation:(float)rotation
                                             atLocation:(CGPoint) location
{
    [self showMessage:@"Rotation gesture"];
}

/**
 * helper function to show a message label when gesture was applied.
 */
-(void)showMessage:(NSString *)message
{
    CGRect frame = CGRectMake(110, 200, 220, 120);

    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor groupTableViewBackgroundColor];
    label.textColor = [UIColor blueColor];
    label.text = message;
    label.numberOfLines = 0;

    CGRect rect = [[label text] boundingRectWithSize:frame.size
                                             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                          attributes:@{NSFontAttributeName:label.font}
                                             context:nil];
    frame.size = rect.size;
    label.frame = frame;

    [self.view addSubview:label];


    [UIView animateWithDuration:2.0 animations:^{label.alpha = 0;}
                                    completion:^(BOOL finished){
                                        [label removeFromSuperview];
                                    }
     ];
}
@end
