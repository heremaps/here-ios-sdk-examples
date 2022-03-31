/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import "ResponseDetailViewController.h"

@interface MainViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *centerTextField;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITextField *collectionSizeTextField;
@property (weak, nonatomic) IBOutlet UITextField *languageTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypeAddressSwith;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypePlaceSwith;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypeCategorySwith;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypeChainSwith;
@property (weak, nonatomic) IBOutlet UISwitch *resultTypeQuerySwith;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;

@end

typedef NS_ENUM(NSUInteger, PickerViewTag) {
    PickerViewTagLanguage = 1,
    PickerViewTagCountry
};

@implementation MainViewController {
    NSArray<NMAAutoSuggest*> *_searchResultData;
    NSArray *_availableLanguages;
    NSMutableArray *_availableCountries;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initializeAvailableLanguages];
    [self initializeAvailableContries];

    [self setupPickerViews];
}

- (NMAPlacesAutoSuggestionResultType)getResultType {
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

    NMAGeoCoordinates* geo = [NMAGeoCoordinates geoCoordinatesWithLatitude:[coords[0] doubleValue]
                                                                 longitude:[coords[1] doubleValue]];
    // Create address filter if specified
    NMAAddressFilter *addressFilter = nil;
    if (_countryTextField.text.length > 0) {
        addressFilter = [NMAAddressFilter new];
        addressFilter.countryCode = _countryTextField.text;
    }

    NMAAutoSuggestionRequest* autoSuggestionRequest
        = [[NMAPlaces sharedPlaces] createAutoSuggestionRequestWithLocation:geo
                                                                partialTerm:text
                                                                 resultType:[self getResultType]
                                                                     filter:addressFilter];

    autoSuggestionRequest.languagePreference = _languageTextField.text;

    // Perform request
    [autoSuggestionRequest startWithBlock:^(NMARequest *request, id data, NSError *error) {
        if (error.code != NMARequestErrorNone) {
            [self showError:error.code];
        } else {
            self->_searchResultData = data;
            [self->_resultTableView reloadData];
        }
    }];
}

-(void)showError:(NSInteger)code {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Searchging"
                                 message:[NSString stringWithFormat:@"Search error: %zd", code]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:nil];

    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIPickerView
- (void)setupPickerViews {
    UIPickerView *languagePickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    languagePickerView.delegate = self;
    languagePickerView.dataSource = self;
    languagePickerView.tag = PickerViewTagLanguage;
    _languageTextField.inputView = languagePickerView;

    UIPickerView *countryPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    countryPickerView.delegate = self;
    countryPickerView.dataSource = self;
    countryPickerView.tag = PickerViewTagCountry;
    _countryTextField.inputView = countryPickerView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == PickerViewTagLanguage) {
        _languageTextField.text = self->_availableLanguages[row];
    } else {
        _countryTextField.text = self->_availableCountries[row];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return pickerView.tag == PickerViewTagLanguage ?
        self->_availableLanguages[row] : self->_availableCountries[row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return pickerView.tag == PickerViewTagLanguage ?
        self->_availableLanguages.count : self->_availableCountries.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark - UITableView

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

-(void)initializeAvailableContries {

    // Get available country codes from iOS system
    NSArray *systemCountryCodes = [NSLocale ISOCountryCodes];
    self->_availableCountries = [NSMutableArray arrayWithCapacity:systemCountryCodes.count + 1];

    // Add empty string to select no country
    [self->_availableCountries addObject:@""];

    // Convert 2-digit long country codes to corresponding 3-digit values
    for (NSString *twoDigitsCode in systemCountryCodes) {
        [self->_availableCountries addObject:[NMACountryInfo toAlpha3CountryCode:twoDigitsCode]];
    }
}

@end
