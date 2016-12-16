/*
 * Copyright © 2011-2016 HERE Europe B.V.
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import "URLTileSource.h"
#import "NMAKit/NMAkit.h"

// URL address to provide image to be downloaded
NSString* const URL = @"https://sites.google.com/site/tilestester/home/bunny_256x256.png";

@implementation URLTileSource

- (id)init
{
    if (self = [super init])
    {
        // Set data source to be self
        self.dataSource = self;
        // Specifies the pixel format of the tile bitmaps to be NMAPixelFormatRGBA
        self.pixelFormat = NMAPixelFormatRGBA;
        // Specifies the tile bitmap is transparent.
        self.transparent = YES;
        // Specifies the cache expiration time in 0 seconds.
        self.cacheTimeToLive = 0;
        // Disable caching of tile data to disk with unique cache identifier
        [self setCacheEnabled:NO withIdentifier:[self description]];
    }

    return self;
}

/**
 * Provide a unique cache identifier
 **/
- (NSString*)description
{
    return [NSString stringWithFormat:@"BunnyURL_%p", self];
}

/**
 * Returns a URL from which the tile bitmap can be downloaded
 **/
- (NSString*)mapTileLayer:(NMAMapTileLayer*)mapTileLayer
            urlForTileAtX:(NSUInteger)x
                        y:(NSUInteger)y
                zoomLevel:(NSUInteger)zoomLevel
{
    return URL;
}

@end
