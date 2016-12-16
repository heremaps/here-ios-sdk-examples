/*
 * Copyright © 2011-2016 HERE Europe B.V.
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import "PlaceDetailViewController.h"
#import "Helper.h"

@interface PlaceDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel* placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* placeLocationLabel;
@end

@implementation PlaceDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Helper showIndicatorOnView:self.view];

    // Fire a PlaceDetail request on the NMAPlaceLink passed from the previous controller.
    [[self.placeLink detailsRequest] startWithBlock:^(
        NMARequest* request, id data, NSError* error) {
        [Helper hideIndicator];
        if ([request isKindOfClass:[NMAPlaceRequest class]] && error.code == NMARequestErrorNone)
        {
            // Display the name and the location of the place.Additional place details info ca also
            // be
            // retrieved at this moment as well.Please refer to the HERE Android SDK API doc for
            // details.
            NMAPlace* place = (NMAPlace*)data;
            self.placeNameLabel.text = place.name;
            NMAGeoCoordinates* position = place.location.position;
            self.placeLocationLabel.text = [NSString
                stringWithFormat:@"Position:%f,%f", position.latitude, position.longitude];
        }
        else
        {
            NSLog(@"Place request returns error with error code:%d", (int)error.code);
        }

    }];
}

@end
