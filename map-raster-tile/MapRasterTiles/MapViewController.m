/*
 * Copyright © 2011-2016 HERE Europe B.V.
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */
#import "MapViewController.h"
#import "ImageTileSource.h"
#import "URLTileSource.h"
#import <NMAKit/NMAKit.h>

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView* mapView;

@property (weak, nonatomic) IBOutlet UISegmentedControl* segmentedCtrl;
@end

@implementation MapViewController
{
    NMAMapTileLayer* _imageSourceTile;
    NMAMapTileLayer* _urlSourceTile;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Create an instance of URL raster tile source
    if (_urlSourceTile == nil)
    {
        _urlSourceTile = [URLTileSource new];
    }
    // Create an instance of Image raster tile source
    if (_imageSourceTile == nil)
    {
        _imageSourceTile = [ImageTileSource new];
    }
}

/**
 * Remove all tile layers which have been added to NMAMapView
 **/
- (void)removeTileLayers
{
    for (id layer in [_mapView mapTileLayers])
    {
        [_mapView removeMapTileLayer:layer];
    }
}

/**
 * Add NMAMapTileLayer when segmented control value changed.
 **/
- (IBAction)segmentedCtrlValueChanged:(id)sender
{
    switch (_segmentedCtrl.selectedSegmentIndex)
    {
    case 0:
        [self removeTileLayers];
        [_mapView addMapTileLayer:_urlSourceTile];
        break;
    case 1:
        [self removeTileLayers];
        [_mapView addMapTileLayer:_imageSourceTile];
        break;

    default:
        break;
    }
}

@end
