/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import "ResponseDetailViewController.h"

@interface MainViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *centerTextField;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITextField *collectionSizeTextField;
@property (weak, nonatomic) IBOutlet UITextField *languageTextField;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypeAddressSwith;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypePlaceSwith;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypeCategorySwith;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypeChainSwith;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypeQuerySwith;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;

@end

@implementation MainViewController {
    IBOutlet UIPickerView *_languagePickerView;
    NSArray<NMAAutoSuggest*> *_searchResultData;
    NSArray *_availableLanguages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeAvailableLanguages];

    _languagePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [_languagePickerView setDataSource:self];
    [_languagePickerView setDelegate:self];
    _languagePickerView.showsSelectionIndicator = YES;
    _languageTextField.inputView = _languagePickerView;
}

- (NMAPlacesAutoSuggestionResultType) getResultType {
    NMAPlacesAutoSuggestionResultType resultType = 0;
    if ([_resultTypeAddressSwith isOn]) {
        resultType ^= NMAPlacesAutoSuggestionResultAddress;
    }
    if ([_resultTypePlaceSwith isOn]) {
        resultType ^= NMAPlacesAutoSuggestionResultPlace;
    }
    if ([_resultTypeCategorySwith isOn]) {
        resultType ^= NMAPlacesAutoSuggestionResultCategory;
    }
    if ([_resultTypeChainSwith isOn]) {
        resultType ^= NMAPlacesAutoSuggestionResultChain;
    }
    if ([_resultTypeQuerySwith isOn]) {
        resultType ^= NMAPlacesAutoSuggestionResultQuery;
    }

    return resultType;
}

- (IBAction)searchButtonClicked:(id)sender {
    [self.view endEditing:YES];
    NSString* text = [_searchTextField text];
    // parse input, it has to have two double values seperated by commas
    NSArray<NSString *>* coords = [[_centerTextField text] componentsSeparatedByString:@","];
    if (coords.count < 2) {
        NSLog(@"Wrong format for geo coordinates");
        return;
    }

    NMAGeoCoordinates* geo = [NMAGeoCoordinates geoCoordinatesWithLatitude:[coords[0] doubleValue] longitude:[coords[1] doubleValue]];
    NMAAutoSuggestionRequest* autoSuggestionRequest
        = [[NMAPlaces sharedPlaces] createAutoSuggestionRequestWithLocation:geo
                                                                partialTerm:text
                                                                 resultType:[self getResultType]];

    autoSuggestionRequest.languagePreference = _languageTextField.text;

    // permorm request
    [autoSuggestionRequest startWithBlock:^(NMARequest *request, id data, NSError *error) {
        if (error.code != NMARequestErrorNone) {
            [self showError:(int) error.code];
        } else {
            self->_searchResultData = data;
            [self->_resultTableView reloadData];
        }
    }];
}

-(void) showError:(int)code {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Searchging"
                                 message:[NSString stringWithFormat:@"Search error: %d", code]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:nil];

    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _languageTextField.text = self->_availableLanguages[row];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self->_availableLanguages[row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self->_availableLanguages.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResultData.count;
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

    NMAAutoSuggest* item = [_searchResultData objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Type:%@", [self typeToString:item.type]];

    NSMutableString* text = [NSMutableString new];
    [text appendFormat:@"Title:%@", item.title];
    [text appendFormat:@"\nHighlighted Title:%@", item.highlightedTitle];

    // Check what type of response we have and populate data based on it
    if ([item isKindOfClass:[NMAAutoSuggestPlace class]]) {
        NMAAutoSuggestPlace* place = (NMAAutoSuggestPlace *) item;
        [text appendFormat:@"\nVicinity: %@", place.vicinityDescription];
        [text appendFormat:@"\nCategory: %@", place.category];
    } else if ([item isKindOfClass:[NMAAutoSuggestQuery class]]) {
        NMAAutoSuggestQuery* query = (NMAAutoSuggestQuery *) item;
        [text appendFormat:@"\nCompletion: %@", query.completion];
    } else if ([item isKindOfClass:[NMAAutoSuggestSearch class]]) {
        NMAAutoSuggestSearch* search = (NMAAutoSuggestSearch *) item;
        [text appendFormat:@"\nCategory: %@", search.category];
    }
    cell.detailTextLabel.text = text;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[_searchResultData objectAtIndex:indexPath.row] isKindOfClass:NMAAutoSuggestQuery.class]) {
        NMAAutoSuggestQuery* query = (NMAAutoSuggestQuery *) [_searchResultData objectAtIndex:indexPath.row];
        [query.autoSuggestionRequest startWithBlock:^(NMARequest*  request, id data, NSError* error) {
            if (data) {
                self->_searchResultData = data;
                [self->_resultTableView reloadData];
                self->_searchTextField.text = query.completion;
            } else {
                NSLog(@"autoSuggestionRequest returns error with error code:%d", (int)error.code);
            }
        }];

    } else {
        [self performSegueWithIdentifier:@"showDetail" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath* indexPath = [self.resultTableView indexPathForSelectedRow];
        ResponseDetailViewController* vc = segue.destinationViewController;
        vc.autoSuggest = [_searchResultData objectAtIndex:indexPath.row];
    }
}

-(NSString*)typeToString:(NMAAutoSuggestType)type {
    switch (type) {
        case NMAAutoSuggestTypePlace:
            return @"Place";
        case NMAAutoSuggestTypeSearch:
            return @"Search";
        case NMAAutoSuggestTypeQuery:
            return @"Query";
        case NMAAutoSuggestTypeUnknown:
            return @"Unknown";
    }
}

-(void)initializeAvailableLanguages {
    self->_availableLanguages = @[
        @"",
        @"af-ZA",
        @"sq-AL",
        @"ar-SA",
        @"az-Latn-AZ",
        @"eu-ES",
        @"be-BY",
        @"bg-BG",
        @"ca-ES",
        @"zh-CN",
        @"zh-TW",
        @"hr-HR",
        @"cs-CZ",
        @"da-DK",
        @"nl-NL",
        @"en-GB",
        @"en-US",
        @"et-EE",
        @"fa-IR",
        @"fil-PH",
        @"fi-FI",
        @"fr-FR",
        @"fr-CA",
        @"gl-ES",
        @"de-DE",
        @"el-GR",
        @"ha-Latn-NG",
        @"he-IL",
        @"hi-IN",
        @"hu-HU",
        @"id-ID",
        @"it-IT",
        @"ja-JP",
        @"kk-KZ",
        @"ko-KR",
        @"lv-LV",
        @"lt-LT",
        @"mk-MK",
        @"ms-MY",
        @"nb-NO",
        @"pl-PL",
        @"pt-BR",
        @"pt-PT",
        @"ro-RO",
        @"ru-RU",
        @"sr-Latn-CS",
        @"sk-SK",
        @"sl-SI",
        @"es-MX",
        @"es-ES",
        @"sv-SE",
        @"th-TH",
        @"tr-TR",
        @"uk-UA",
        @"uz-Latn-UZ",
        @"vi-VN"
    ];
}

@end
