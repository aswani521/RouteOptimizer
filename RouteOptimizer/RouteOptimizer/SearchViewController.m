//
//  SearchViewController.m
//  RouteOptimizer
//
//  Created by Aswani Nerella on 11/25/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "SearchViewController.h"
#import "MapViewController.h"
#import "SearchResultCell.h"
#import "DirectionsHelper.h"
#import "MapSearchViewController.h"
@import GoogleMaps;

@interface SearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate, GMSAutocompleteFetcherDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *startAddress;
@property (strong, nonatomic) IBOutlet UITextField *endAddress;
@property (strong, nonatomic) IBOutlet UITextField *searchTerm;
//TODO: THIS NEEDS TO ANIMATE (MAYBE USE ADLivelyCollectionView)
//TODO: ANIMATE this on screen on textField touch, and animate the textField up with it!!!!
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapToDismissGestureRecognizer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *autoCompleteHeight;
@property (strong, nonatomic) IBOutlet UICollectionView *searchResultCollectionView;

@property (nonatomic, assign) SearchType selectedSearchType;
@property (nonatomic, strong) GMSAutocompleteFetcher *placesFetcher;
@property (nonatomic, strong) NSMutableArray *currentSearchResults;

@property (nonatomic, strong) NSString *initialStartText;
@property (nonatomic, strong) NSString *initialEndText;
@property (nonatomic, strong) NSString *initialSecondaryText;

@end

@implementation SearchViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Select Locations";
    
    self.searchResultCollectionView.delegate = self;
    self.searchResultCollectionView.dataSource = self;
    [self.searchResultCollectionView registerNib:[UINib nibWithNibName:@"SearchResultCell" bundle:nil] forCellWithReuseIdentifier:@"SearchResultCell"];
    
    self.currentSearchResults = [NSMutableArray array];
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
    self.placesFetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:nil filter:filter];
    self.placesFetcher.delegate = self;
    
    self.tapToDismissGestureRecognizer.delegate = self;
    [self.tapToDismissGestureRecognizer addTarget:self action:@selector(touchOffInput)];
    
    self.startAddress.text = self.initialStartText;
    self.endAddress.text = self.initialEndText;
    self.searchTerm.text = self.initialSecondaryText;
}

- (void)setInitialRouteStart:(NSString *)start end:(NSString *)end andSecondaries:(NSArray *)secondaries {
    self.initialStartText = start;
    self.initialEndText = end;
    self.initialSecondaryText = [secondaries firstObject];
}

- (IBAction)findRouteButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)originDidBeginEditing:(UITextField *)sender {
    self.selectedSearchType = SearchTypeOrigin;
    [self setupForAutoCompleteWithText:sender.text];
}

- (IBAction)destinationDidBeginEditing:(UITextField *)sender {
    self.selectedSearchType = SearchTypeDestination;
    [self setupForAutoCompleteWithText:sender.text];
}

- (IBAction)secondaryDestinationDidBeginEditing:(UITextField *)sender {
    self.selectedSearchType = SearchTypeSecondary;
    [self setupForAutoCompleteWithText:sender.text];
}

- (IBAction)searchEditingDidEnd:(UITextField *)sender {
    self.autoCompleteHeight.constant = 0;
    [self.view layoutIfNeeded];
}

# pragma mark - UICollectionViewDataSource delegate methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.currentSearchResults.count > 0) {
        return self.currentSearchResults.count + 1;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    
    // The first cell should always be to search for the current term
    // Otherwise set the map with the place the user selected
    if (cell) {
        if (indexPath.row == 0) {
            switch (self.selectedSearchType) {
                case SearchTypeOrigin:
                    [cell setupWithSearchData:[NSString stringWithFormat:@"Search: %@", self.startAddress.text]];
                    break;
                case SearchTypeDestination:
                    [cell setupWithSearchData:[NSString stringWithFormat:@"Search: %@", self.endAddress.text]];
                    break;
                case SearchTypeSecondary:
                    [cell setupWithSearchData:[NSString stringWithFormat:@"Search: %@", self.searchTerm.text]];
                    break;
            }
        } else {
            [cell setupWithPlaceData:self.currentSearchResults[indexPath.row - 1]];
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.searchResultCollectionView.frame.size.width, 50);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == 0) {
        switch (self.selectedSearchType) {
            case SearchTypeOrigin:
                [self placeSearchWithText:self.startAddress.text];
                break;
            case SearchTypeDestination:
                [self placeSearchWithText:self.endAddress.text];
                break;
            case SearchTypeSecondary:
                [self placeSearchWithText:self.searchTerm.text];
                break;
        }
    } else {
        GMSAutocompletePrediction *selectedPlace = self.currentSearchResults[indexPath.row - 1];
        
        if (selectedPlace) {
            GMSPlacesClient *placesClient = [[GMSPlacesClient alloc] init];
            [placesClient lookUpPlaceID:selectedPlace.placeID callback:^(GMSPlace *place, NSError *error) {
                if (error != nil) {
                    NSLog(@"Place Details error %@", [error localizedDescription]);
                    return;
                }
                
                if (place != nil) {
                    switch (self.selectedSearchType) {
                        case SearchTypeOrigin:
                            self.startAddress.text = place.formattedAddress;
                            break;
                        case SearchTypeDestination:
                            self.endAddress.text = place.formattedAddress;
                            break;
                        case SearchTypeSecondary:
                            self.searchTerm.text = place.formattedAddress;
                            break;
                    }
                    
                    [self.delegate completedSearchForPlace:place withType:self.selectedSearchType];
                } else {
                    NSLog(@"No place details for place");
                }
            }];
        }
    }
    
    self.autoCompleteHeight.constant = 0;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item (Not needed just yet)
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    // The motions happen so fast that this is not relly showing. Maybe it'll show if we animate
    SearchResultCell *cell = (SearchResultCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setHighlighted:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    // The motions happen so fast that this is not relly showing. Maybe it'll show if we animate
    SearchResultCell *cell = (SearchResultCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setHighlighted:NO];
}

- (void)placeSearchWithText:(NSString *)text {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapSearchViewController *mapSearchVc = [storyboard instantiateViewControllerWithIdentifier:@"MapSearchViewController"];
    [mapSearchVc setSearchTerm:text]; // This initiates the remote calls necessary to retrieve the relevant place data
    //mapSearchVc.delegate = self;
    
    [self.navigationController pushViewController:mapSearchVc animated:YES];
}

- (IBAction)searchTextDidChange:(UITextField *)sender {
    [self.placesFetcher sourceTextHasChanged:sender.text];
}

#pragma mark - GMSAutocompleteFetcherDelegate

- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    self.currentSearchResults = [[NSMutableArray alloc] initWithArray:predictions];
    [self.searchResultCollectionView reloadData];
    for (GMSAutocompletePrediction *prediction in predictions) {
        NSLog(@"%@", prediction);
    }
}

- (void)didAutocompleteWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    NSLog(@"%@", error);
}


#pragma mark UIGestureRecognizerDelegate method

// Only neccessary to make sure we deselect everyting when the user clicks outside of the textfield or collection view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.searchResultCollectionView]) {
        
        // Don't let selections of auto-complete entries fire the 
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

// Handles de-selection when user clicks on whitespace
- (void)touchOffInput {
    self.searchResultCollectionView.hidden = YES;
    [self.startAddress resignFirstResponder];
    [self.endAddress resignFirstResponder];
    [self.searchTerm resignFirstResponder];
    self.autoCompleteHeight.constant = 0;
    [self.view layoutIfNeeded];
}

// Presents the autocomplete collection view
// We should animate this
- (void)setupForAutoCompleteWithText:(NSString *)initialText {
    self.autoCompleteHeight.constant = 300;
    if (initialText.length > 0) {
        [self.placesFetcher sourceTextHasChanged:initialText];
    } else {
        self.currentSearchResults = [NSMutableArray array];
        [self.searchResultCollectionView reloadData];
    }
    [self.view layoutIfNeeded];
}

@end