/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

#import "NMAKit/NMAkit.h"

/**
 * A layer of custom raster tiles for display in an NMAMapView.
 * This custom raster tile is supplied as bitmap data (png image) and can be supplied synchronously,
 * asynchronously
 * IMPORTANT! The properties of this interface should not be modified after the instance
 * has been added to an NMAMapView.
 */

@interface ImageTileSource : NMAMapTileLayer <NMAMapTileLayerDataSource>

@end
