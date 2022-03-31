/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

#import "ResponseDetailViewController.h"

@interface ResponseDetailViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ResponseDetailViewController {
    NSArray<NMALink *>* _discoveryResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // perform detail request for these types of autoSuggest
    if ([self.autoSuggest isKindOfClass:[NMAAutoSuggestPlace class]]) {
        NMAAutoSuggestPlace* place = (NMAAutoSuggestPlace *) self.autoSuggest;
        [place.placeDetailsRequest startWithBlock:^(NMARequest* request, id data, NSError* error) {
            if (data) {
                NMAPlace* place = (NMAPlace*)data;
                NSMutableString* lableText = [NSMutableString new];
                [lableText appendFormat:@"Name: %@",  place.name];
                [lableText appendFormat:@"\nAlternative names:"];

                for (NSString* key in place.alternativeNames) {
                    [lableText appendFormat:@"\n%@=%@", key, [place.alternativeNames objectForKey:key]];
                }
                self.labelDescription.text = lableText;
            } else {
                NSLog(@"placeDetailsRequest returns error with error code:%d", (int)error.code);
            }
        }];
    } else if ([self.autoSuggest isKindOfClass:[NMAAutoSuggestSearch class]]) {
        self.tableView.hidden = NO;
        self->_tableView.dataSource = self;
        NMAAutoSuggestSearch* search = (NMAAutoSuggestSearch *) self.autoSuggest;
        [search.suggestedSearchRequest startWithBlock:^(NMARequest* request, id data, NSError* error) {
            if (data) {
                NMADiscoveryPage* page = (NMADiscoveryPage*)data;
                self->_discoveryResults = page.discoveryResults;
                [self->_tableView reloadData];
            } else {
                NSLog(@"suggestedSearchRequest returns error with error code:%d", (int)error.code);
            }
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _discoveryResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.numberOfLines = 1;
    cell.detailTextLabel.numberOfLines = 5;
    [cell.textLabel sizeToFit];

    NMALink* item = [_discoveryResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Name:%@", item.name];

    if ([item isKindOfClass:NMAPlaceLink.class]) {
        NSMutableString* text = [NSMutableString new];
        NMAPlaceLink* placeLink = (NMAPlaceLink*)item;
        [text appendFormat:@"%@Vicinity:%@", text, placeLink.vicinityDescription];
        [text appendFormat:@"%@\nCategory:%@", text, placeLink.category.name];
        [text appendFormat:@"%@\nDistance:%ld", text, placeLink.distance];
        cell.detailTextLabel.text = text;
    }

    return cell;
}

@end
