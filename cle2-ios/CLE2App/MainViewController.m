/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import <NMAKit/NMAKit.h>

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet NMAMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *layerNameTextFiled;
@property (weak, nonatomic) IBOutlet UISlider *searchRadiusSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *connectivityModeControl;

@end

@implementation MainViewController {
    NSMutableArray<NMACLE2Geometry *> *_geometries;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //create geo coordinate
    NMAGeoCoordinates *geoCoordCenter =
    [[NMAGeoCoordinates alloc] initWithLatitude:49.260327 longitude:-123.115025];
    //set map view with geo center
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    //set zoom level
    self.mapView.zoomLevel = 13.2;

    self.layerNameTextFiled.delegate = self;
    self.connectivityModeControl.selectedSegmentIndex = 2;

    _geometries = [NSMutableArray array];
}

- (void)clearMap {
    [self.mapView removeAllMapObjects];
    [_geometries removeAllObjects];
}

- (void)addGeometry:(NMACLE2GeometryPoint *)geometry {
    [_geometries addObject:geometry];

    // Create map marker object
    NMAImage* markerImage = [NMAImage imageWithUIImage:[UIImage imageNamed:@"marker.png"]];
    NMAMapMarker *marker = [[NMAMapMarker alloc] initWithGeoCoordinates:geometry.coordinates
                                                                   icon:markerImage];
    [self.mapView addMapObject:marker];
}

- (void)displayDialogWithTitle:(NSString *)title
                       message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:okButton];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - User actions

/**
 * Download all layer data from remote storage
 */
- (IBAction)downloadButtonPressed:(id)sender {
    [self clearMap];

    // create download layer task
    NMACLE2Task<NMACLE2OperationResult *> *task = [[NMACLE2DataManager sharedManager] downloadLayerTask:self.layerNameTextFiled.text];

    // start downloading
    [task startWithBlock:^(NMACLE2OperationResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            [self displayDialogWithTitle:@"Download error" message:error.description];
            return;
        }

        NSString *message = [NSString stringWithFormat:@"%@ geometries downloaded.", result.affectedItemCount];
        [self displayDialogWithTitle:@"Layer Download Completed" message:message];

        NMACLE2Task<NSMutableArray<NMACLE2Geometry *> *> *fetchTask;
        fetchTask = [[NMACLE2DataManager sharedManager] fetchLocalLayersTask:[NSArray arrayWithObjects:self.layerNameTextFiled.text, nil]];

        // now fetch geometry from local storage
        [fetchTask startWithBlock:^(NSMutableArray<NMACLE2Geometry *> * _Nullable result, NSError * _Nullable error) {
            if (error) {
                [self displayDialogWithTitle:@"Fetch error" message:error.description];
                return;
            }

            for (NMACLE2GeometryPoint *point in result) {
                [self addGeometry:point];
            }
        }];
    }];
}

/**
 * Upload all layer data to remote storage
 */
- (IBAction)uploadButtonPressed:(id)sender {
    // create upload layer task
    NMACLE2Task<NMACLE2OperationResult *> *task = [[NMACLE2DataManager sharedManager] uploadLayerTask:self.layerNameTextFiled.text
                                                                                       withGeometries:_geometries];

    // start uploading
    [task startWithBlock:^(NMACLE2OperationResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            [self displayDialogWithTitle:@"Upload error" message:error.description];
            return;
        }

        NSString *message = [NSString stringWithFormat:@"%@ geometries uploaded.", result.affectedItemCount];
        [self displayDialogWithTitle:@"Layer Upload Completed" message:message];
    }];
}

- (IBAction)clearMapButtonPressed:(id)sender {
    [self clearMap];
}

- (IBAction)addGeometryButtonPressed:(id)sender {
    // add some geometry to map using map center
    NMACLE2GeometryPoint *point = [[NMACLE2GeometryPoint alloc] init];
    point.coordinates = self.mapView.geoCenter;

    [self addGeometry:point];
}

- (IBAction)purgeLocalStoragePressed:(id)sender {
    // create purge local storage task
    NMACLE2Task<NMACLE2OperationResult *> *task = [[NMACLE2DataManager sharedManager] purgeLocalStorageTask];

    // start purging
    [task startWithBlock:^(NMACLE2OperationResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            [self displayDialogWithTitle:@"Purge error" message:error.description];
            return;
        }

        NSString *message = [NSString stringWithFormat:@"%@ geometries purged.", result.affectedItemCount];
        [self displayDialogWithTitle:@"Purge Local Storage Completed" message:message];
    }];
}

/**
 * Demonstration of the proximity search feature.
 * Search for all geometries from the center of the map in the desired search radius.
 */
- (IBAction)searchPressed:(id)sender {
    [self clearMap];

    NMAMapCircle *circle = [[NMAMapCircle alloc] initWithGeoCoordinates:self.mapView.geoCenter
                                                                 radius:self.searchRadiusSlider.value];

    circle.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
    [self.mapView addMapObject:circle];

    // create proximity search request using map center as center.
    NMACLE2ProximityRequest *request = [[NMACLE2ProximityRequest alloc] initWithLayer:self.layerNameTextFiled.text
                                                                               center:self.mapView.geoCenter
                                                                               radius:self.searchRadiusSlider.value];

    // set desired connectivity mode
    // if the connectivity mode is OFFLINE, the geometries will be searched in local storage,
    // otherwise in remote storage.
    switch (self.connectivityModeControl.selectedSegmentIndex) {
        case 0:
            request.connectivityMode = NMACLE2ConnectivityModeOnline;
            break;
        case 1:
            request.connectivityMode = NMACLE2ConnectivityModeOffline;
            break;
        default:
            request.connectivityMode = NMACLE2ConnectivityModeAutomatic;
            break;
    }

    // execute the request
    [request startWithBlock:^(NMACLE2Request * _Nonnull request, NMACLE2Result * _Nonnull result, NSError * _Nullable error) {
        if (error) {
            [self displayDialogWithTitle:@"Search error" message:error.description];
            return;
        }

        for (NMACLE2GeometryPoint *point in result.geometriesArray) {
            [self addGeometry:point];
        }

        NSString *message = [NSString stringWithFormat:@"%lu geometries found.", result.geometriesArray.count];
        [self displayDialogWithTitle:@"Proxymity Search Completed" message:message];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
