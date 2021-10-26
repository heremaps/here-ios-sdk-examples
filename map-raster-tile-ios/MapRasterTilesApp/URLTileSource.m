/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "URLTileSource.h"
#import "NMAKit/NMAKit.h"

// URL address to provide image to be downloaded
NSString* const URL = @"https://raw.githubusercontent.com/heremaps/here-ios-sdk-examples/master/misc/bunny.png";

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
