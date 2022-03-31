/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (nonatomic) NSArray* infos;
@property (nonatomic) NSArray* titles;

@property (nonatomic) NSDictionary* mapSchemes;
@property (nonatomic) NSArray* transitModes;

@property (nonatomic, weak) UISegmentedControl* mapSchemeCtrl;
@property (nonatomic, weak) UISegmentedControl* transitModeCtrl;
@property (nonatomic, weak) UISwitch* flowSwitch;
@property (nonatomic, weak) UISwitch* incidentSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapSchemes = @{
        @"NORMAL_DAY" : NMAMapSchemeNormalDay,
        @"HYBRID_DAY" : NMAMapSchemeHybridDay,
        @"TERRAIN_DAY" : NMAMapSchemeTerrainDay
    };
    self.transitModes = @[ @"NOTHING", @"STOP_AND_ACCESSE", @"EVERYTHING" ];
    self.titles = @[
        @"Map Schemes", @"Transit Mode Attributes", @"Traffic Layer Attributes"
    ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{

    return [self.titles count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 2)
        return 2;
    else
        return 1;
}

/**
 * Add segmetned switches for map scheme and transit mode, switch for traffic layer.
 **/
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    UITableViewCell* cell;

    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentedCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"SegmentedCell"];
        }
        UISegmentedControl* mapSchemeCtrl =
            [[UISegmentedControl alloc] initWithItems:[self.mapSchemes allKeys]];

        NSDictionary* textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14.0]};
        [mapSchemeCtrl setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [mapSchemeCtrl setTitleTextAttributes:textAttributes forState:UIControlStateHighlighted];
        self.mapSchemeCtrl = mapSchemeCtrl;
        [cell.contentView addSubview:mapSchemeCtrl];

        NSInteger index = [[self.mapSchemes allValues] indexOfObject:_mapScheme];
        if (index != NSNotFound)
            mapSchemeCtrl.selectedSegmentIndex = index;

        mapSchemeCtrl.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary* metrics = @{ @"ctrl" : mapSchemeCtrl };
        [cell.contentView
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[ctrl]-(10)-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:metrics]];
        [cell.contentView
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[ctrl]-(10)-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:metrics]];
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentedCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"SegmentedCell"];
        }
        UISegmentedControl* transitModeCtrl =
            [[UISegmentedControl alloc] initWithItems:_transitModes];

        NSDictionary* textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12.0]};
        [transitModeCtrl setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [transitModeCtrl setTitleTextAttributes:textAttributes forState:UIControlStateHighlighted];
        self.transitModeCtrl = transitModeCtrl;
        [cell.contentView addSubview:transitModeCtrl];

        transitModeCtrl.selectedSegmentIndex = (NSInteger)_transitDisplayMode;

        transitModeCtrl.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary* metrics = @{ @"ctrl" : transitModeCtrl };
        [cell.contentView
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[ctrl]-(10)-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:metrics]];
        [cell.contentView
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[ctrl]-(10)-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:metrics]];
    }
    else if (indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"SwitchCell"];
        }

        switch (indexPath.row)
        {
        case 0:
        {
            cell.textLabel.text = @"FLOW";
            UISwitch* flowSwitch = [[UISwitch alloc] init];
            cell.accessoryView = flowSwitch;
            flowSwitch.on = _trafficLayers & NMATrafficLayerFlow;
            self.flowSwitch = flowSwitch;
            break;
        }
        case 1:
        {
            cell.textLabel.text = @"INCIDENT";
            UISwitch* incidentSwitch = [[UISwitch alloc] init];
            cell.accessoryView = incidentSwitch;
            incidentSwitch.on = _trafficLayers & NMATrafficLayerIncidents;
            self.incidentSwitch = incidentSwitch;
            break;
        }
        default:
            break;
        }
    }
    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title;
    title = [self.titles objectAtIndex:section];
    return title;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1)
    {
        return 50.0;
    }
    return 40.0;
}

/**
 * It gets selection for map scheme
 **/
- (void)getMapSchemeSettings
{
    NSInteger segmentIndex = self.mapSchemeCtrl.selectedSegmentIndex;
    _mapScheme = [[self.mapSchemes allValues] objectAtIndex:segmentIndex];
}

/**
 * It gets selection for transit mode
 **/
- (void)getTransitModeSettings
{
    NSInteger segmentIndex = self.transitModeCtrl.selectedSegmentIndex;
    _transitDisplayMode = (NMAMapTransitDisplayMode)(segmentIndex);
}

/**
 * It gets selection for traffic layer
 **/
- (void)getTrafficLayersSettings
{
    _trafficLayers = 0;
    if (self.flowSwitch.isOn)
        _trafficLayers ^= NMATrafficLayerFlow;
    if (self.incidentSwitch.isOn)
        _trafficLayers ^= NMATrafficLayerIncidents;
}

/**
 * When cancel button is pressed, it calls delegates to perform.
 **/
- (IBAction)cancelBtnPressed:(id)sender
{
    [self.delegate settingsViewControllerDidCancel:self];
}

/**
 * When done button is clicked, it gets all selection for map attributes and
 *calls delegate to perform.
 **/
- (IBAction)doneBtPressed:(id)sender
{
    [self getMapSchemeSettings];
    [self getTransitModeSettings];
    [self getTrafficLayersSettings];
    [self.delegate settingsViewControllerDidDone:self];
}
@end
