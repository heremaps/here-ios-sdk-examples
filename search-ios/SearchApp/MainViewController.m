/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import "Helper.h"
#import "ResultTableViewController.h"
#import <NMAKit/NMAKit.h>

typedef void (^NMARequestCompletionBlock)(NMARequest* request, id data, NSError* error);

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView* mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* requestControl;
@property (nonatomic) NSMutableArray* mapObjectsArray;
@property (weak, nonatomic) IBOutlet UIButton* resultListButton;
@property (nonatomic) NSArray* resultsArray;
@property (nonatomic) NMADiscoveryPage* resultPage;
@property (nonatomic, copy) NMARequestCompletionBlock completionBlock;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // create geo coordinate
    NMAGeoCoordinates* geoCoordCenter =
        [[NMAGeoCoordinates alloc] initWithLatitude:49.260327 longitude:-123.115025];
    // set map view with geo center
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    // set zoom level
    self.mapView.zoomLevel = 13.2;
    self.requestControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    self.resultListButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view bringSubviewToFront:self.resultListButton];
    self.resultListButton.hidden = YES;
    self.mapObjectsArray = [[NSMutableArray alloc] init];

    // Initialize a request completion block
    __weak typeof(self) weakSelf = self;
    self.completionBlock = ^(NMARequest* request, id data, NSError* error) {

        if (error.code != NMARequestErrorNone)
        {
            NSLog(@"discovery request error %d", (int)error.code);
            return;
        }

        if (![data isKindOfClass:[NMADiscoveryPage class]])
        {
            NSLog(@"invalid type returned %@", data);
            return;
        }
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
        {
            return;
        }
        // No error returned.Let's handle the results
        strongSelf.resultListButton.hidden = NO;
        [Helper hideIndicator];

        // The result is a DiscoveryResultpage object which represents a paginated collection of
        // items.The items can be either a PlaceLink or DiscoveryLink.The PlaceLink can be used to
        // retrieve place details by firing another PlaceRequest,while the DiscoveryLink is designed
        // to be used to fire another DiscoveryRequest to obtain more refined results.
        strongSelf.resultPage = (NMADiscoveryPage*)data;
        strongSelf.resultsArray = strongSelf.resultPage.discoveryResults;
        for (NMALink* item in strongSelf.resultsArray)
        {
            // Add a marker for each result of PlaceLink type.For best usability, map can be also
            // adjusted to display all markers.This can be done by merging the bounding box of each
            // result and then zoom the map to the merged one.
            if ([item isKindOfClass:[NMAPlaceLink class]])
            {
                [strongSelf addMarkerAtPlace:(NMAPlaceLink*)item];
            }
        }

    };
}

- (IBAction)handleRequestControl:(id)sender
{
    // Trigger the request
    [self cleanMap];
    switch (self.requestControl.selectedSegmentIndex)
    {
    case 0:
        [self triggerAroundRequest];
        break;
    case 1:
        [self triggerExploreRequest];
        break;
    case 2:
        [self triggerHereRequest];
        break;
    case 3:
        [self triggerSearchRequest];
        break;
    default:
        break;
    }
    [Helper showIndicatorOnView:self.view];
}

- (void)triggerSearchRequest
{
    // Trigger a SearchRequest based on the current map center and search query "Hotel".Please refer
    // to HERE Mobile SDK for iOS API doc for other supported location parameters and categories
    NMADiscoveryRequest* searchRequest =
        [[NMAPlaces sharedPlaces] createSearchRequestWithLocation:[self.mapView geoCenter]
                                                            query:@"Hotel"];
    NSError* error = [searchRequest startWithBlock:self.completionBlock];
    if (error.code != NMARequestErrorNone)
    {
        [Helper
            showMessage:[NSString stringWithFormat:@"Error:search request fired with error code %d",
                                  (int)error.code]
                 OnView:self.view];
        [Helper hideIndicator];
    }
}

- (void)triggerHereRequest
{
    // Trigger a HereRequest based on the current map center.Please refer to HERE Mobile SDK for iOS API
    // doc for othe supported location parameters and categories.
    NMADiscoveryRequest* hereRequest =
        [[NMAPlaces sharedPlaces] createHereRequestWithLocation:[self.mapView geoCenter]
                                                        filters:nil];
    NSError* error = [hereRequest startWithBlock:self.completionBlock];
    if (error.code != NMARequestErrorNone)
    {
        [Helper
            showMessage:[NSString stringWithFormat:@"Error:here request fired with error code %d",
                                  (int)error.code]
                 OnView:self.view];
        [Helper hideIndicator];
    }
}

- (void)triggerExploreRequest
{
    // Trigger an ExploreRequest based on the bounding box of the current map and the filter for
    // Shopping category.Please refer to HERE Mobile SDK for iOS API doc for other supported location
    // parameters and categories
    NMACategoryFilter* filter = [NMACategoryFilter new];
    [filter addCategoryFilterFromUniqueId:@"shopping"];
    NMADiscoveryRequest* exploreRequest =
        [[NMAPlaces sharedPlaces] createExploreRequestWithLocation:nil
                                                        searchArea:[self.mapView boundingBox]
                                                           filters:filter];
    NSError* error = [exploreRequest startWithBlock:self.completionBlock];
    if (error.code != NMARequestErrorNone)
    {
        [Helper showMessage:[NSString
                                stringWithFormat:@"Error:explore request fired with error code %d",
                                (int)error]
                     OnView:self.view];
        [Helper hideIndicator];
    }
}

- (void)triggerAroundRequest
{
    // Trigger and AroundRequest based on the current map center and the filter for Eat&Drink
    // category.Please refer to HERE Mobile SDK for iOS API doc for other supported location parameters and
    // categories
    NMACategoryFilter* filter = [NMACategoryFilter new];
    [filter addCategoryFilterFromUniqueId:@"eat-drink"];
    NMADiscoveryRequest* aroundRequest =
        [[NMAPlaces sharedPlaces] createAroundRequestWithLocation:[self.mapView geoCenter]
                                                       searchArea:nil
                                                          filters:filter];
    NSError* error = [aroundRequest startWithBlock:self.completionBlock];
    if (error.code != NMARequestErrorNone)
    {
        [Helper
            showMessage:[NSString stringWithFormat:@"Error:around request fired with error code %d",
                                  (int)error]
                 OnView:self.view];
        [Helper hideIndicator];
    }
}

- (void)addMarkerAtPlace:(NMAPlaceLink*)placeLink
{
    NMAImage* img = [NMAImage imageWithUIImage:[UIImage imageNamed:@"marker.png"]];

    NMAMapMarker* mapMarker =
        [[NMAMapMarker alloc] initWithGeoCoordinates:[placeLink position] icon:img];

    [self.mapView addMapObject:mapMarker];
    [self.mapObjectsArray addObject:mapMarker];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    // Pass the search results to the next view controller
    if ([segue.identifier isEqualToString:@"ResultTableView"])
    {
        UINavigationController* navigationController = segue.destinationViewController;
        ResultTableViewController* resultTableViewController =
            [navigationController viewControllers].firstObject;
        resultTableViewController.resultsArray = self.resultsArray;
    }
}

- (void)cleanMap
{
    if ([self.mapObjectsArray count] > 0)
    {
        [self.mapView removeMapObjects:self.mapObjectsArray];
        [self.mapObjectsArray removeAllObjects];
    }
    self.resultListButton.hidden = YES;
}

@end
