/*
 * Copyright © 2011-2016 HERE Global B.V. and its affiliate(s).
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import "MainViewController.h"
#import <NMAKit/NMAKit.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl* requestControl;
@property (weak, nonatomic) IBOutlet UITextView* resultTextView;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.resultTextView.editable = NO;
    self.requestControl.selectedSegmentIndex = UISegmentedControlNoSegment;
}

- (IBAction)handleRequestControl:(id)sender
{
    self.resultTextView.text = @"";
    switch (self.requestControl.selectedSegmentIndex)
    {
    case 0:
        [self triggerGeocodeRequest];
        break;
    case 1:
        [self triggerRevGeocodeRequest];
        break;
    default:
        break;
    }
}

- (void)triggerGeocodeRequest
{
    // Create a GeocodeRequest object with the desired query string, then set the search area by
    // providing a Geocoordinate and radius before executing the request
    NSString* query = @"4350 Still Creek Dr,Burnaby";
    NMAGeoCoordinates* coordinate =
        [NMAGeoCoordinates geoCoordinatesWithLatitude:49.266787 longitude:-123.056640];
    NMAGeocodeRequest* request =
        [[NMAGeocoder sharedGeocoder] createGeocodeRequestWithQuery:query
                                                       searchRadius:5000
                                                       searchCenter:coordinate];
    [request startWithBlock:^(NMARequest* request, id data, NSError* error) {
        NSString* resultString = @"";
        if (error.code != NMARequestErrorNone)
        {
            resultString =
                [NSString stringWithFormat:@"Geocoder request error %d", (int)error.code];
            self.resultTextView.text = resultString;
            return;
        }

        if (![request isKindOfClass:[NMAGeocodeRequest class]])
        {
            resultString = [NSString stringWithFormat:@"invalid type returned %@", data];
            self.resultTextView.text = resultString;
            return;
        }
        NSMutableArray* results = (NSMutableArray*)data;
        // From the array of NMAGeocodeResult object,we retrieve the coordinate information and
        // display to the screen.Please refer to HERE Android SDK doc for other supported APIs.
        for (NMAGeocodeResult* result in results)
        {
            NMAGeoCoordinates* position = result.location.position;
            resultString = [resultString
                stringByAppendingString:[NSString stringWithFormat:@"%f,%f\n", position.latitude,
                                                  position.longitude]];
        }
        self.resultTextView.text = resultString;
    }];
}

- (void)triggerRevGeocodeRequest
{
    // Create a ReverseGeocodeRequest object with a GeoCoordinate
    NMAGeoCoordinates* coordinate =
        [NMAGeoCoordinates geoCoordinatesWithLatitude:49.25914 longitude:-123.00777];
    NMAReverseGeocodeRequest* request =
        [[NMAGeocoder sharedGeocoder] createReverseGeocodeRequestWithGeoCoordinates:coordinate];
    [request startWithBlock:^(NMARequest* request, id data, NSError* error) {
        NSString* resultString = @"";
        if (error.code != NMARequestErrorNone)
        {
            resultString =
                [NSString stringWithFormat:@"RevGeocoder request error %d", (int)error.code];
            self.resultTextView.text = resultString;
            return;
        }

        if (![request isKindOfClass:[NMAReverseGeocodeRequest class]])
        {
            resultString = [NSString stringWithFormat:@"invalid type returned %@", data];
            self.resultTextView.text = resultString;
            return;
        }

        NSMutableArray* results = (NSMutableArray*)data;

        // From the array of NMARevGeocodeResult object, we retrieve the address of the 1st element
        // and display to the screen.Please refer to HERE Android SDK doc for other support APIs.
        NMAAddress* address
            = ((NMAReverseGeocodeResult*)[results objectAtIndex:0]).location.address;
        resultString = [NSString stringWithFormat:@"%@\n", address.formattedAddress];
        self.resultTextView.text = resultString;
    }];
}

@end
