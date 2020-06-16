/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"

NSString* const FloatSchemeName = @"float";
NSString* const ColorSchemeName = @"color";

@implementation MainViewController {
    NMAZoomRange* _zoomRange;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //set segmented control titles attributes
    UIFont* font = [UIFont boldSystemFontOfSize:14.0f];
    NSDictionary* attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [self.segmentCtrl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];


    [self.segmentCtrl addTarget:self action:@selector(segmentedCtrlClicked) forControlEvents:UIControlEventValueChanged];
    self.segmentCtrl.selectedSegmentIndex = -1;

    //set zoom range
    _zoomRange = [[NMAZoomRange alloc] initWithMinZoomLevel:0.0f maxZoomLevel:20.0f];
}

/**
 * when segmented ctrol was clicked, it either create customized map scheme for color property or float property
 */
- (void)segmentedCtrlClicked {
    switch (self.segmentCtrl.selectedSegmentIndex) {
        case 0:
            //if first segmented clicked, create customized map scheme for specific color property
            [self createMapSchemeForColorProperty];
            break;
        case 1:
            //if second segmented clicked, create customized map scheme for specific float property
            [self createMapSchemeForFloatProperty];
            break;
        default:
            break;
    }
}

/**
 * create customized map scheme for color property
 */
- (void)createMapSchemeForColorProperty {
    //if customized map scheme already exists, remove it first.
    if ([self.mapView getCustomizableSchemeWithName:FloatSchemeName] != nil) {
        //it is not allowed to remove map scheme which is active.
        //set to other map scheme then remove.
        [self.mapView setMapScheme:NMAMapSchemeNormalDay];
        [self.mapView removeCustomizableSchemeWithName:FloatSchemeName];

    }
    
    //create customizable scheme with specific scheme name based on NMAMapSchemeNormalDay
    if (self.colorScheme == nil) {
        self.colorScheme = [self.mapView createCustomizableSchemeWithName:ColorSchemeName
                                         basedOnScheme:NMAMapSchemeNormalDay];
    }
    
    //create customizable color for property NMASchemeBuildingColor for specific zoom level
    NMACustomizableColor* buildingColor =
        [self.colorScheme colorForProperty:NMASchemeBuildingColor forZoomLevel:18.0f];
    [buildingColor setRed:100];
    [buildingColor setGreen:100];
    [buildingColor setBlue:133];
    //set color property
    [self.colorScheme setColorProperty:buildingColor forZoomRange:_zoomRange];
    //set map scheme to be customized scheme
    [self.mapView setMapScheme:ColorSchemeName];
    [self.mapView setGeoCenter:[[NMAGeoCoordinates alloc] initWithLatitude:52.500556 longitude:13.398889]
                     zoomLevel:18.0f
                 withAnimation:NMAMapAnimationNone];
}

/**
 * create customized map scheme for float property
 */
- (void)createMapSchemeForFloatProperty {
    //if customized map scheme already exists, remove it first.
    if ([self.mapView getCustomizableSchemeWithName:ColorSchemeName] != nil) {
        //it is not allowed to remove map scheme which is active.
        //set to other map scheme then remove.
        [self.mapView setMapScheme:NMAMapSchemeNormalDay];
        [self.mapView removeCustomizableSchemeWithName:ColorSchemeName];
    }
    
    //create customizable scheme with specific scheme name based on NMAMapSchemeNormalDay
    if (self.floatScheme == nil) {
        self.floatScheme = [self.mapView createCustomizableSchemeWithName:FloatSchemeName
                                         basedOnScheme:NMAMapSchemeNormalDay];
    }
    
    //set its float property boundary width to be 10.0 for specific zoom range
    [self.floatScheme setFloatProperty:NMASchemeCountryBoundaryWidth withValue:10.0f forZoomRange:_zoomRange];
    //set map scheme to be customized scheme
    [self.mapView setMapScheme:FloatSchemeName];
    [self.mapView setZoomLevel:4.0];
}
@end
