/*
 * Copyright © 2011-2016 HERE Global B.V. and its affiliate(s).
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
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
