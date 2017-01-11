/*
 * Copyright (c) 2011-2017 HERE Europe B.V.
 * All rights reserved.
 */

#import "MapPackageTableViewController.h"
#import "MapPackageTableCellTableViewCell.h"

@interface MapPackageTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView* mapPackageTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* mapUpdateButton;
@property (nonatomic) NMAMapLoader* mapLoader;
@property (nonatomic)
    NSMutableArray* currentPackages; // Map packages currently displayed in the table view.
@property (nonatomic) UILabel* progressLabel;

@end

@implementation MapPackageTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initMapLoader];
}

- (void)initMapLoader
{
    // Instantiate a MapLoader
    self.mapLoader = [NMAMapLoader sharedMapLoader];
    self.mapLoader.delegate = self;

    // Obtain the current state of the map package hierachies.
    [self.mapLoader getMapPackages];
}

- (IBAction)didCancelButtonClick:(id)sender
{
    // Cancel the current MapLoader operation.
    Boolean success = [self.mapLoader cancelCurrentOperation];
    if (success)
    {
        self.progressLabel.text = @"Cancelling....";
    }
    else
    {
        [self showAlertWithMessage:@"No ongoing Maploader operations to be cancelled."];
    }
}
- (IBAction)didUpdateButtonClick:(id)sender
{
    // Check map update.
    Boolean success = [self.mapLoader checkForMapDataUpdate];
    if (!success)
    {
        [self showAlertWithMessage:@"MapLoader is being busy with other operations"];
    }
}

// Helper function to refresh the table view.Please note that for code simplicity, this app
// refreshes the table view to display the highest level of the map hierachies i.e continent map
// whenever a map installation/un-installation has been completed.Application developers can
// implement their own logic in this case to handle how they want to present to end users.
- (void)refreshMapPackageTableWithArray:(NSMutableArray*)mapPackages
{
    self.currentPackages = mapPackages;
    [self.tableView reloadData];
}

// Helper function to pop up an alert window
- (void)showAlertWithMessage:(NSString*)message
{
    UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:nil
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    int duration = 1;
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
}

#pragma mark - MapLoader delegate protocols
- (void)mapLoader:(NMAMapLoader*)mapLoader
    didGetPackagesWithResult:(NMAMapLoaderResult)mapLoaderResult
{
    if (mapLoaderResult == NMAMapLoaderResultSuccess)
    {
        // Please note that to get the latest MapPackage status,the application should always access
        // the rootPackage property of the maploader.
        NMAMapPackage* root = self.mapLoader.rootPackage;
        [self refreshMapPackageTableWithArray:(NSMutableArray*)root.children];
    }
    else
    {
        [self showAlertWithMessage:
                  [NSString
                      stringWithFormat:@"MapLoader failed to get map packages with error code %lu",
                      mapLoaderResult]];
    }
}

- (void)mapLoader:(NMAMapLoader*)mapLoader
    didFindUpdate:(BOOL)updateIsAvailable
      fromVersion:(NSString*)currentMapVersion
        toVersion:(NSString*)newestMapVersion
       withResult:(NMAMapLoaderResult)mapLoaderResult
{
    if (mapLoaderResult == NMAMapLoaderResultSuccess)
    {
        if (updateIsAvailable)
        {
            // Update map if there is a new version available
            [self showAlertWithMessage:[NSString stringWithFormat:@"Found new map version %@",
                                                 newestMapVersion]];
            Boolean success = [self.mapLoader performMapDataUpdate];
            if (!success)
            {
                [self showAlertWithMessage:@"MapLoader is being busy with other operations"];
            }
        }
        else
        {
            [self
                showAlertWithMessage:[NSString
                                         stringWithFormat:@"Current map version %@ is the latest.",
                                         currentMapVersion]];
        }
    }
}

- (void)mapLoader:(NMAMapLoader*)mapLoader didUpdateWithResult:(NMAMapLoaderResult)mapLoaderResult
{
    if (mapLoaderResult == NMAMapLoaderResultSuccess)
    {
        NMAMapPackage* root = self.mapLoader.rootPackage;
        [self refreshMapPackageTableWithArray:(NSMutableArray*)root.children];
    }
}

- (void)mapLoader:(NMAMapLoader*)mapLoader didUpdateProgress:(float)progress
{
    if (progress < 1.0)
    {
        self.progressLabel.text = [NSString stringWithFormat:@"Progress:%f", progress];
    }
    else
    {
        self.progressLabel.text = @"Installing...";
    }
}

- (void)mapLoader:(NMAMapLoader*)mapLoader
    didInstallPackagesWithResult:(NMAMapLoaderResult)mapLoaderResult
{
    self.progressLabel.text = @"";
    if (mapLoaderResult == NMAMapLoaderResultSuccess)
    {
        NMAMapPackage* root = self.mapLoader.rootPackage;
        [self refreshMapPackageTableWithArray:(NSMutableArray*)root.children];
    }
    else if (mapLoaderResult == NMAMapLoaderResultOperationCancelled)
    {
        [self showAlertWithMessage:@"Installation is cancelled..."];
    }
}

- (void)mapLoader:(NMAMapLoader*)mapLoader
    didUninstallPackagesWithResult:(NMAMapLoaderResult)mapLoaderResult
{
    self.progressLabel.text = @"";
    if (mapLoaderResult == NMAMapLoaderResultSuccess)
    {
        NMAMapPackage* root = self.mapLoader.rootPackage;
        [self refreshMapPackageTableWithArray:(NSMutableArray*)root.children];
    }
    else if (mapLoaderResult == NMAMapLoaderResultOperationCancelled)
    {
        [self showAlertWithMessage:@"Uninstallation is cancelled..."];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentPackages count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellIdentifier = @"mapPackageTableCell";
    MapPackageTableCellTableViewCell* cell = (MapPackageTableCellTableViewCell*)[tableView
        dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray* nib =
            [[NSBundle mainBundle] loadNibNamed:@"MapPackageTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NMAMapPackage* mapPackage = [self.currentPackages objectAtIndex:indexPath.row];

    // Display title and size information of each map package.Please refer to HERE iOS SDK API doc
    // for all support APIs.
    cell.mapPackageTitleLabel.text = mapPackage.title;

    switch (mapPackage.installationStatus)
    {
    case NMAMapPackageInstallationNone:
        cell.mapPackageStatusLabel.text = @"Not Installed";
        break;
    case NMAMapPackageInstallationExplicit:
        cell.mapPackageStatusLabel.text = @"Installed";
        break;
    case NMAMapPackageInstallationImplicit:
        cell.mapPackageStatusLabel.text = @"Installed by parent";
        break;
    default:
        break;
    }

    // sizeOnDisk property represents the maximum size of a map pacakge.If there are some pacakges
    // alreay been installed, the actual size consumed may be smaller because of the shared data
    // between packages.
    cell.mapPackageSizeLabel.text = [NSString stringWithFormat:@"%lu KB", mapPackage.sizeOnDisk];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NMAMapPackage* selectedPackage = [self.currentPackages objectAtIndex:indexPath.row];
    MapPackageTableCellTableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];

    if ([selectedPackage.children count] > 0)
    {
        // Children map pacakges exist.Refresh the table view.
        [self refreshMapPackageTableWithArray:(NSMutableArray*)selectedPackage.children];
    }
    else
    {
        // No children map packages.Perform either downloading or uninstallation action.
        self.progressLabel = selectedCell.mapPackageProgressLabel;
        NSArray* packageArray = [[NSArray alloc] initWithObjects:selectedPackage, nil];
        if (selectedPackage.installationStatus == NMAMapPackageInstallationImplicit
            || selectedPackage.installationStatus == NMAMapPackageInstallationExplicit)
        {
            Boolean success = [self.mapLoader uninstallMapPackages:packageArray];
            if (!success)
            {
                [self showAlertWithMessage:@"MapLoader is being busy with other operations"];
            }
            else
            {
                self.progressLabel.text = @"Uninstalling...";
            }
        }
        else
        {
            Boolean success = [self.mapLoader installMapPackages:packageArray];
            if (!success)
            {
                [self showAlertWithMessage:@"MapLoader is being busy with other operations"];
            }
        }
    }
}
@end
