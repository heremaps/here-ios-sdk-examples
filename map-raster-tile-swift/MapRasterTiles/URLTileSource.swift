/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

/**
 * A layer of custom raster tiles for display in an NMAMapView.
 *
 * This custom raster tile is supplied by providing a URL from which to download the tiles from
 *
 * IMPORTANT! The properties of this interface should not be modified after the instance
 * has been added to an NMAMapView.
 */

// URL address to provide image to be downloaded
let URL = "https://github.com/heremaps/here-ios-sdk-examples/blob/master/misc/bunny.png"

class URLTileSource: NMAMapTileLayer, NMAMapTileLayerDataSource {

    override init () {
        super.init()

        self.dataSource = self
        // Specifies the pixel format of the tile bitmaps to be NMAPixelFormatRGBA
        self.pixelFormat = NMAPixelFormat.RGBA
        // Specifies the tile bitmap is transparent.
        self.isTransparent = true
        // Specifies the cache expiration time in 0 seconds.
        self.cacheTimeToLive = 0
        // Disable caching of tile data to disk with unique cache identifier
        self.setCacheEnabled(false, identifier: self.description)
    }

    /**
     * Provide a unique cache identifier
     **/
    override var description : String {
        return String(format: "BunnyURL_%p", self)
    }

    /**
     * Returns a URL from which the tile bitmap can be downloaded
     **/
    func mapTileLayer(_ mapTileLayer: NMAMapTileLayer,
                      urlForTileAt x: UInt, _ y: UInt, _ zoomLevel: UInt) -> String {
        return URL
    }
}
