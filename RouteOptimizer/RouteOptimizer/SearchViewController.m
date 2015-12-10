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
#import "SearchPlaceModel.h"
#import "DirectionsHelper.h"
#import "MapSearchViewController.h"
@import GoogleMaps;

float const kDestinationToStopsHeight = 8;
float const kStopsContainerHeight = 46;

@interface SearchViewController () <SearchResultCellDelegate, GMSAutocompleteFetcherDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *startAddress;
@property (strong, nonatomic) IBOutlet UITextField *endAddress;
//TODO: THIS NEEDS TO ANIMATE (MAYBE USE ADLivelyCollectionView)
//TODO: ANIMATE this on screen on textField touch, and animate the textField up with it!!!!
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *stopsContainerViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *destinationToStopsHeightConstraint;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapToDismissGestureRecognizer;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *autoCompleteHeight;

@property (nonatomic, assign) SearchType selectedSearchType;
@property (nonatomic, strong) GMSAutocompleteFetcher *placesFetcher;
@property (nonatomic, strong) DirectionsModel *currentDirectionsModel;
@property (nonatomic, strong) NSMutableDictionary *directionsModelsForCurrentSearchResults;
@property (nonatomic, strong) NSMutableArray *currentSearchResults;
@property (nonatomic, strong) NSString *initialStartText;
@property (nonatomic, strong) NSString *initialEndText;
@property (nonatomic, strong) NSString *initialSecondaryText;
@property (nonatomic, assign) StopInputViewcontroller *stopInputViewController;

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
    CLLocationCoordinate2D neBoundsCorner = CLLocationCoordinate2DMake(50.736455, -48.515625);
    CLLocationCoordinate2D swBoundsCorner = CLLocationCoordinate2DMake(19.642588, -126.914063);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:neBoundsCorner
                                                                       coordinate:swBoundsCorner];
    self.placesFetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds filter:filter];
    self.placesFetcher.delegate = self;
    
    self.tapToDismissGestureRecognizer.delegate = self;
    [self.tapToDismissGestureRecognizer addTarget:self action:@selector(touchOffInput)];
    
    self.startAddress.text = self.initialStartText;
    self.endAddress.text = self.initialEndText;
    
    self.directionsModelsForCurrentSearchResults = [NSMutableDictionary dictionary];
    
    self.stopsContainerViewHeightConstraint.constant = 0;
    self.destinationToStopsHeightConstraint.constant = 8;
}

- (void)setInitialRouteStart:(NSString *)start end:(NSString *)end andSecondaries:(NSArray *)secondaries {
    self.initialStartText = start;
    self.initialEndText = end;
    self.initialSecondaryText = [secondaries firstObject];
}

- (void)setCurrentDirectionsModel:(DirectionsModel *)directionsModel {
    _currentDirectionsModel = directionsModel;
}

- (void)animateStopsInputOpen {
    [UIView animateWithDuration:3.25 animations:^{
        self.stopsContainerViewHeightConstraint.constant = kStopsContainerHeight;
        self.destinationToStopsHeightConstraint.constant = 0;
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"StopInputViewControllerSegue"]) {
        self.stopInputViewController = (StopInputViewcontroller *)(segue.destinationViewController);
        self.stopInputViewController.delegate = self;
    }
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

- (IBAction)searchEditingDidEnd:(UITextField *)sender {
    //self.autoCompleteHeight.constant = 0;
    [self.delegate autoCompleteSizeDidChange:0];
    [self.view layoutIfNeeded];
}

# pragma mark - UICollectionViewDataSource delegate methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [collectionView.collectionViewLayout invalidateLayout];
    
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
        cell.delegate = self;
        if (indexPath.row == 0) {
            switch (self.selectedSearchType) {
                case SearchTypeOrigin:
                    [cell setupWithSearchData:[NSString stringWithFormat:@"Search: %@", self.startAddress.text]];
                    break;
                case SearchTypeDestination:
                    [cell setupWithSearchData:[NSString stringWithFormat:@"Search: %@", self.endAddress.text]];
                    break;
            }
        } else {
            GMSAutocompletePrediction *prediction = self.currentSearchResults[indexPath.row-1];
            [cell setupWithPlaceData:prediction existingDirections:self.currentDirectionsModel andNewDirections:self.directionsModelsForCurrentSearchResults[prediction.placeID]];
            //[cell setupWithPlaceData:self.currentSearchResults[indexPath.row - 1]];
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate autoCompleteSizeDidChange:collectionView.contentSize.height];
    //return collectionView.contentSize;
    return CGSizeMake(self.searchResultCollectionView.frame.size.width, 54);
}

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
                //[self placeSearchWithText:self.searchTerm.text];
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
                            [self.stopInputViewController didCompleteSelectionForPlaceWithAddress:place.formattedAddress];
                            break;
                    }
                    
                    [self.delegate completedSearchForPlace:place withType:self.selectedSearchType];
                } else {
                    NSLog(@"No place details for place");
                }
            }];
        }
    }
    
    [self.delegate autoCompleteSizeDidChange:0];
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
    [DirectionsHelper placeSearchWithText:text onComplete:^(NSArray *places, NSError *error) {
        NSMutableArray *searchPlaces = [NSMutableArray array];
        for (NSDictionary *place in places) {
            [searchPlaces addObject:[[SearchPlaceModel alloc] initWithDictionary:place]];
        }
        [self.delegate completedFullSearchWithResults:searchPlaces];
    }];
    //UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //MapSearchViewController *mapSearchVc = [storyboard instantiateViewControllerWithIdentifier:@"MapSearchViewController"];
    //[mapSearchVc setSearchTerm:text]; // This initiates the remote calls necessary to retrieve the relevant place data
    //mapSearchVc.delegate = self;
    
    //[self.navigationController pushViewController:mapSearchVc animated:YES];
}

- (IBAction)searchTextDidChange:(UITextField *)sender {
    if (sender.text.length == 0) {
        [self.delegate autoCompleteSizeDidChange:0];
    }
    
    [self.placesFetcher sourceTextHasChanged:sender.text];
}

#pragma mark - GMSAutocompleteFetcherDelegate

- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    self.currentSearchResults = [[NSMutableArray alloc] initWithArray:predictions];
    [self.searchResultCollectionView reloadData];
    self.directionsModelsForCurrentSearchResults = [NSMutableDictionary dictionary];
    
    if (self.selectedSearchType == SearchTypeSecondary && self.currentDirectionsModel) {
        // Use directions helper to get all distance offsets
        for (GMSAutocompletePrediction *prediction in predictions) {
            [DirectionsHelper plotDirectionsGivenStart:self.currentDirectionsModel.startAddress destination:self.currentDirectionsModel.endAddress andSecondaryDestinations:@[prediction.attributedFullText.string] onComplete:^(DirectionsModel *directions, NSError *error) {
                if (directions) {
                    self.directionsModelsForCurrentSearchResults[prediction.placeID] = directions;
                    [self.searchResultCollectionView reloadData];
                }
            }];
        }
    }
    
    [self.searchResultCollectionView.collectionViewLayout invalidateLayout];
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


#pragma mark - UIGestureRecognizerDelegate method

// Only neccessary to make sure we deselect everyting when the user clicks outside of the textfield or collection view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.searchResultCollectionView]) {
        
        // Don't let selections of auto-complete entries fire the 
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

#pragma mark - SearchResultCellDelegate methods

- (void)detailsWasTouchedForPlace:(NSString *)placeIdentifier {
    [self.delegate detailsTouchedForPlaceIdentifier:placeIdentifier];
}

#pragma mark - StopInpuCell delegate methods

- (void)stopDestinationDidBeginEditing:(UITextField *)textField {
    self.selectedSearchType = SearchTypeSecondary;
    [self setupForAutoCompleteWithText:textField.text];
}

- (void)stopDestinationDidEndEditing:(UITextField *)textField {
    [self.delegate autoCompleteSizeDidChange:0];
    [self.view layoutIfNeeded];
}

- (void)stopDestinationSearchTextDidChange:(UITextField *)textField {
    if (textField.text.length == 0) {
        [self.delegate autoCompleteSizeDidChange:0];
    }
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:self.currentDirectionsModel.northeastBound
                                                                       coordinate:self.currentDirectionsModel.southwestBound];
    self.placesFetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds filter:filter];
    self.placesFetcher.delegate = self;
    
    [self.placesFetcher sourceTextHasChanged:textField.text];
}

#pragma mark - StopInputViewController delegate methods

- (void)removeStopWithFormattedAddress:(NSString *)formattedAddress {
    [self.delegate removeStopWithFormattedAddress:formattedAddress];
}

// Handles de-selection when user clicks on whitespace
- (void)touchOffInput {
    self.searchResultCollectionView.hidden = YES;
    [self.startAddress resignFirstResponder];
    [self.endAddress resignFirstResponder];
    [self.stopInputViewController resignFirstResponder]; // ? Not sure if this will work
    [self.view layoutIfNeeded];
}

// Presents the autocomplete collection view
// We should animate this
- (void)setupForAutoCompleteWithText:(NSString *)initialText {
    if (initialText.length > 0) {
        [self.placesFetcher sourceTextHasChanged:initialText];
    } else {
        self.currentSearchResults = [NSMutableArray array];
        [self.searchResultCollectionView reloadData];
    }
    [self.view layoutIfNeeded];
}

@end
