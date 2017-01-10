/*
 * Copyright © 2011-2016 HERE Global B.V. and its affiliate(s).
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import "ImageTileSource.h"

@implementation ImageTileSource

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
    return [NSString stringWithFormat:@"image_source_%p", self];
}

/**
 * Return raw tile bitmap data for the specified tile.
 **/
- (NSData*)mapTileLayer:(NMAMapTileLayer*)mapTileLayer
    requestDataForTileAtX:(NSUInteger)x
                        y:(NSUInteger)y
                zoomLevel:(NSUInteger)zoomLevel
{
    UIImage* pandaImg = [UIImage imageNamed:@"panda.png"];
    NSData* data = [UIImagePNGRepresentation(pandaImg)
        base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString* base64Image = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData* decodedData =
        [[NSData alloc] initWithBase64EncodedString:base64Image
                                            options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return decodedData;
}
@end
