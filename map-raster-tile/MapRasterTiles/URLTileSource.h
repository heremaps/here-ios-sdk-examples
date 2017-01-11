/*
 * Copyright (c) 2011-2017 HERE Europe B.V.
 * All rights reserved.
 */

#import "NMAKit/NMAkit.h"

/**
 * A layer of custom raster tiles for display in an NMAMapView.
 *
 * This custom raster tile is supplied by providing a URL from which to download the tiles from
 *
 * IMPORTANT! The properties of this interface should not be modified after the instance
 * has been added to an NMAMapView.
 */
@interface URLTileSource : NMAMapTileLayer <NMAMapTileLayerDataSource>

@end
