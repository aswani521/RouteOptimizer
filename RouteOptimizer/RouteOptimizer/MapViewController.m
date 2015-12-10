//
//  ViewController.m
//  RouteOptimizer
//
//  Created by  Minett on 11/19/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "MapViewController.h"
#import "SearchViewController.h"
#import "SearchResultCell.h"
#import "DirectionsHelper.h"
#import "MapSearchResultCell.h"
#import "MerchantDetailsView.h"
#import "DirectionsModel.h"

float const kSearchHeightWithStops = 162;
float const kSearchHeightWithoutStops = 120;
float const kSuggestionsHeight = 92;
float const kSummaryHeight = 64;

@interface MapViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, SearchViewControllerDelegate, StopInputViewControllerDelegate, GMSMapViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *searchContainerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *autoCompleteHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchCollectionHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *suggestionsHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *summaryHeightConstraint;
@property (strong, nonatomic) IBOutlet UICollectionView *autocompleteCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *searchCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *durationDistanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *etaLabel;
@property (strong, nonatomic) IBOutlet GMSMapView *baseMapView;

@property (nonatomic, strong) SearchViewController *searchViewController;
@property (nonatomic, strong) DirectionsModel *currentDirectionsModel;
@property (nonatomic, strong) GMSPolyline *mapLine;
@property (nonatomic, strong) GMSMarker *startMarker;
@property (nonatomic, strong) GMSMarker *endMarker;
@property (nonatomic, strong) GMSMarker *currentSecondaryMarker;
@property (nonatomic, strong) NSMutableDictionary *secondaryMarkers;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL initialLocationSet;
@property (nonatomic, strong) CLLocationManager *locationManager;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self setNeedsStatusBarAppearanceUpdate];
    //[self.navigationController.navigationBar setBackgroundColor:self.searchContainerView.backgroundColor];
    
    self.secondaryPlaces = [NSMutableDictionary dictionary];
    
    //UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"directionsIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(directionsBtnClicked:)];
    //self.navigationItem.rightBarButtonItem = searchButton;
    //self.navigationItem.title = @"RouteOptimizer";
    
    // TODO update to only init/perform/ask when user requests to use location
    // TODO update to only init/perform/ask when user requests to use location
    // TODO update to only init/perform/ask when user requests to use location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    // TODO update to only init/perform/ask when user requests to use location
    // TODO update to only init/perform/ask when user requests to use location
    // TODO update to only init/perform/ask when user requests to use location

    // TODO come back to the initial setup of the camera for this view. If we have the location use it!
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.424912
                                                            longitude:-122.136598
                                                                 zoom:10];
    //self.baseMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.baseMapView.delegate = self;
    self.baseMapView.camera = camera;
    self.baseMapView.myLocationEnabled = YES;
    //[self.baseMapView animateToLocation:self.baseMapView.myLocation.coordinate];
    self.mapLine = [[GMSPolyline alloc] init];

    self.startMarker = [[GMSMarker alloc] init];
    self.endMarker = [[GMSMarker alloc] init];
    self.secondaryMarkers = [NSMutableDictionary dictionary];

    //[self.baseMapView insertSubview:self.baseMapView atIndex:0];
    //[self.baseMapView insertSubview:self.autocompleteCollectionView atIndex:0];
    [self.baseMapView addSubview:self.autocompleteCollectionView];
    //self.autoCompleteHeightConstraint.constant = kSearchHeightWithoutStops;
    
    [self.baseMapView addSubview:self.searchCollectionView];
    self.searchCollectionView.dataSource = self;
    self.searchCollectionView.delegate = self;
    self.searchCollectionHeightConstraint.constant = 0;
    self.suggestionsHeightConstraint.constant = 0;
    self.summaryHeightConstraint.constant = 0;
    self.containerViewHeightConstraint.constant = kSearchHeightWithoutStops;
    [self.searchCollectionView registerNib:[UINib nibWithNibName:@"MapSearchResultCell" bundle:nil] forCellWithReuseIdentifier:@"MapSearchResultCell"];

    [self updateMapRoute];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateMapRoute];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SearchViewControllerSegue"]) {
        self.searchViewController = (SearchViewController *)(segue.destinationViewController);
        self.searchViewController.delegate = self;
        self.searchViewController.searchResultCollectionView = self.autocompleteCollectionView;
        //self.autocompleteCollectionView.delegate = svc;
        //self.autocompleteCollectionView.dataSource = svc;
    }
}

- (void)updateMapRoute {
    NSLog(@"Start Address: %@ End Address: %@",self.startPlace, self.destinationPlace);
    NSMutableArray *secondaries = [NSMutableArray array];
    
    for (GMSPlace *place in [self.secondaryPlaces allValues]) {
        //[secondaries addObject:[NSString stringWithFormat:@"place_id:%@", place.placeID]];
        [secondaries addObject:place.formattedAddress];
    }
    
    //[DirectionsHelper plotDirectionsGivenStart:@"San Francisco, CA"//self.startPlace.name
    //                               destination:@"San Diego, CA"//self.destinationPlace.name
    [DirectionsHelper plotDirectionsGivenStart:self.startPlace.formattedAddress
                                   destination:self.destinationPlace.formattedAddress
                                andSecondaryDestinations:secondaries
                                    onComplete:^(DirectionsModel *directionsModel, NSError *error) {
                                        self.currentDirectionsModel = directionsModel;
                                        self.mapLine.map = nil;
                                        self.mapLine = self.currentDirectionsModel.mapLine;
                                        self.mapLine.map = self.baseMapView;
                                        
                                        if (self.currentDirectionsModel) {
                                                NSDate *now = [NSDate date];
                                                NSDate *eta = [now dateByAddingTimeInterval:self.currentDirectionsModel.durationInSeconds];
                                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                [formatter setDateFormat:@"hh:mm a"];
                                                NSLog(@"Current Date: %@", [formatter stringFromDate:[NSDate date]]);
                                                NSString *etaTime = [formatter stringFromDate:eta];
                                                self.etaLabel.text = [NSString stringWithFormat:@"%@ ETA", etaTime];
                                                
                                                self.durationDistanceLabel.text = [NSString stringWithFormat:@"%0.1f min - %0.1f mi", self.currentDirectionsModel.durationInMinutes, self.currentDirectionsModel.distanceInMiles];
                                            
                                            if (self.containerViewHeightConstraint.constant != kSearchHeightWithStops) {
                                                [self.searchViewController animateStopsInputOpen];
                                                
                                                [UIView animateWithDuration:1.0 animations:^{
                                                    self.containerViewHeightConstraint.constant = kSearchHeightWithStops;
                                                    self.summaryHeightConstraint.constant = kSummaryHeight;
                                                    self.suggestionsHeightConstraint.constant = kSuggestionsHeight;
                                                    [self.view layoutIfNeeded];
                                                }];
                                            }
                                            
                                            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:self.currentDirectionsModel.southwestBound coordinate:self.currentDirectionsModel.northeastBound];
                                            GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:40.0f];
                                            [self.baseMapView moveCamera:update];
                                        }
                                        
                                        [self.searchViewController setCurrentDirectionsModel:self.currentDirectionsModel];
                                    }];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.initialLocationSet) {
        [self.baseMapView animateToLocation:[locations lastObject].coordinate];
        self.initialLocationSet = true;
    }
}

- (void)directionsBtnClicked:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *searchViewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    
    // Allows this MapViewController to be notified of selections of locations
    searchViewController.delegate = self;
    
    NSMutableArray *secondaries = [NSMutableArray array];
    for (GMSPlace *place in [self.secondaryPlaces allValues]) {
        [secondaries addObject:place.name];
    }
    [searchViewController setInitialRouteStart:self.startPlace.name end:self.destinationPlace.name andSecondaries:secondaries];
    
    self.secondaryMarkers = [NSMutableDictionary dictionary];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - SearchViewController delegate methods

- (void)autoCompleteSizeDidChange:(float)autocomleteHeight {
    // Maybe constrain this between 0 and 200
    self.searchViewController.searchResultCollectionView.hidden = NO;
    self.autoCompleteHeightConstraint.constant = autocomleteHeight;
}

- (void)completedFullSearchWithResults:(NSArray *)searchPlaces {
    self.searchResults = [[NSMutableArray alloc] initWithArray:searchPlaces];
    [self.searchCollectionView reloadData];
}

- (void)completedSearchForPlace:(GMSPlace *)place withType:(enum SearchType) searchType {
    switch (searchType) {
        case SearchTypeOrigin:
            self.startPlace = place;
            
            // Reset old marker
            self.startMarker.map = nil;
            
            self.startMarker = [[GMSMarker alloc] init];
            self.startMarker.position = self.startPlace.coordinate;
            self.startMarker.snippet = self.startPlace.formattedAddress;
            self.startMarker.appearAnimation = kGMSMarkerAnimationPop;
            self.startMarker.map = self.baseMapView;
            self.startMarker.icon = [UIImage imageNamed:@"location_marker.png"];
            break;
        case SearchTypeDestination:
            self.destinationPlace = place;
            
            // Reset old marker
            self.endMarker.map = nil;
            
            self.endMarker = [[GMSMarker alloc] init];
            self.endMarker.position = self.destinationPlace.coordinate;
            self.endMarker.snippet = self.destinationPlace.formattedAddress;
            self.endMarker.appearAnimation = kGMSMarkerAnimationPop;
            self.endMarker.map = self.baseMapView;
            self.endMarker.icon = [UIImage imageNamed:@"location_marker.png"];
            break;
        case SearchTypeSecondary:
            self.currentSecondaryMarker = [[GMSMarker alloc] init];
            
            self.currentSecondaryMarker = [[GMSMarker alloc] init];
            self.currentSecondaryMarker.position = place.coordinate;
            self.currentSecondaryMarker.snippet = place.formattedAddress;
            self.currentSecondaryMarker.appearAnimation = kGMSMarkerAnimationPop;
            self.currentSecondaryMarker.map = self.baseMapView;
            self.currentSecondaryMarker.icon = [UIImage imageNamed:@"location_marker.png"];
            self.secondaryMarkers[place.formattedAddress] = self.currentSecondaryMarker;
            self.secondaryPlaces[place.formattedAddress] = place;
            break;
    }
    
    if (self.startPlace && self.destinationPlace) {
        [self updateMapRoute];
    }
}

- (void)detailsTouchedForPlaceIdentifier:(NSString *)placeIdentifier {
    
    [DirectionsHelper placeSearchWithText:placeIdentifier onComplete:^(NSArray *places, NSError *error) {
        SearchPlaceModel *searchPlace = [[SearchPlaceModel alloc] initWithDictionary:[places firstObject]];
        //MerchantDetailsView *mdvc = [[MerchantDetailsView alloc] initWithNibName:@"MerchantDetailsView" bundle:nil];
        MerchantDetailsView *mdvc = [[MerchantDetailsView alloc]init];
        //Setup with searchPlace here
        //[mdvc setupWithSearchPlace:searchPlace];

        mdvc.MerchantPlace = searchPlace;
        [self.navigationController pushViewController:mdvc animated:YES];
    }];
}

#pragma mark - StopInputViewController delegate methods

- (void)removeStopWithFormattedAddress:(NSString *)formattedAddress {
    [self.secondaryPlaces removeObjectForKey:formattedAddress];
    GMSMarker *marker = self.secondaryMarkers[formattedAddress];
    marker.map = nil;
    [self.secondaryMarkers removeObjectForKey:formattedAddress];
    [self updateMapRoute];
}

#pragma mark - GMSMapViewDelegate methods

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    [self detailsTouchedForPlaceIdentifier:marker.snippet];
}

# pragma mark - UICollectionViewDataSource delegate methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MapSearchResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MapSearchResultCell" forIndexPath:indexPath];
    
    if (cell) {
        [cell setupCellWithSearchPlaceData:self.searchResults[indexPath.row]];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.searchCollectionView.frame.size.width, 50); // Will not be size 50
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item (Not needed just yet)
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    // The motions happen so fast that this is not relly showing. Maybe it'll show if we animate
    MapSearchResultCell *cell = (MapSearchResultCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setHighlighted:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    // The motions happen so fast that this is not relly showing. Maybe it'll show if we animate
    MapSearchResultCell *cell = (MapSearchResultCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setHighlighted:NO];
}

@end