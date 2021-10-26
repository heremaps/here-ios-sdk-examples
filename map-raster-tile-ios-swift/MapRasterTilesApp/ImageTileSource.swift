/*
 * Copyright (c) 2011-2021 HERE Europe B.V.
 * All rights reserved.
 */

import NMAKit

/**
 * A layer of custom raster tiles for display in an NMAMapView.
 * This custom raster tile is supplied as bitmap data (png image) and can be supplied synchronously,
 * asynchronously
 * IMPORTANT! The properties of this interface should not be modified after the instance
 * has been added to an NMAMapView.
 */

class ImageTileSource: NMAMapTileLayer, NMAMapTileLayerDataSource {

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
        return String(format: "image_source_%p", self)
    }

    /**
     * Return raw tile bitmap data for the specified tile.
     **/
    func mapTileLayer(_ mapTileLayer: NMAMapTileLayer,
                      requestDataForTileAt x: UInt, _ y: UInt, _ zoomLevel: UInt) -> Data {
        if let pandaImg = UIImage(named: "panda.png") {
            if let data = pandaImg.pngData()?
                .base64EncodedData(options: Data.Base64EncodingOptions.lineLength64Characters) {
                if let base64Image = String(data: data, encoding: String.Encoding.utf8) {
                    if let decodedData = Data(base64Encoded: base64Image,
                        options: Data.Base64DecodingOptions.ignoreUnknownCharacters) {
                        return decodedData
                    }
                }
            }
        }
        return Data()
    }
}
