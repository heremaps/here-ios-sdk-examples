/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

#import "ResultTableViewController.h"
#import "Helper.h"
#import "PlaceDetailViewController.h"
#import <NMAKit/NMAKit.h>

@interface ResultTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView* resultTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* backButton;
@end

@implementation ResultTableViewController

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsArray count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    static NSString* cellIdentifier = @"tableCell";

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }

    // Display vicinity information of each NMAPlaceLink item.Please refer to HERE iOS SDK API
    // doc for all supported APIs.
    NMALink* link = [self.resultsArray objectAtIndex:indexPath.row];
    if ([link isKindOfClass:[NMAPlaceLink class]])
    {
        [cell.textLabel setText:((NMAPlaceLink*)link).vicinityDescription];
    }
    else if ([link isKindOfClass:[NMADiscoveryLink class]])
    {
        [cell.textLabel setText:@"This is a DiscoveryLink"];
    }
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self performSegueWithIdentifier:@"PlaceDetailView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PlaceDetailView"])
    {
        NSIndexPath* indexPath = [self.resultTableView indexPathForSelectedRow];
        PlaceDetailViewController* placeDetailViewController = segue.destinationViewController;
        // Pass the selected NMAPlaceLink object to the next view controller for retrieving place
        // details.
        NMALink* link = [self.resultsArray objectAtIndex:indexPath.row];
        if ([link isKindOfClass:[NMAPlaceLink class]])
        {
            placeDetailViewController.placeLink = (NMAPlaceLink*)link;
        }
        else
        {
            [Helper showMessage:@"The item selected is a DiscoveryLink" OnView:self.view];
        }
    }
}

- (IBAction)onBackButtonClicked:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
