//
//  ViewController.m
//  RouteOptimizer
//
//  Created by  Minett on 11/19/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "MapViewController.h"
#import "SearchViewController.h"
#import "DirectionsHelper.h"

@interface MapViewController () <CLLocationManagerDelegate, SearchViewControllerDelegate>
@property (nonatomic, strong) GMSPlacePicker *placePicker;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSPolyline *mapLine;
@property (nonatomic, strong) GMSMarker *startMarker;
@property (nonatomic, strong) GMSMarker *endMarker;
@property (nonatomic, strong) GMSMarker *currentSecondaryMarker;
@property (nonatomic, strong) NSMutableArray *secondaryMarkers;
@property (nonatomic, assign) BOOL initialLocationSet;
@property (nonatomic, strong) CLLocationManager *locationManager;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.secondaryPlaces = [NSMutableArray array];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"directionsIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(directionsBtnClicked:)];
    self.navigationItem.rightBarButtonItem = searchButton;
    self.navigationItem.title = @"RouteOptimizer";
    
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.352011
                                                            longitude:-121.882324
                                                                 zoom:10];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    [self.mapView animateToLocation:self.mapView.myLocation.coordinate];
    self.mapLine = [[GMSPolyline alloc] init];

    self.startMarker = [[GMSMarker alloc] init];
    self.endMarker = [[GMSMarker alloc] init];
    self.secondaryMarkers = [NSMutableArray array];

    self.view = self.mapView;

    [self updateMapRoute];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateMapRoute];
}

- (void)updateMapRoute {
    NSLog(@"Start Address: %@ End Address: %@",self.startPlace, self.destinationPlace);
    NSMutableArray *secondaries = [NSMutableArray array];
    
    for (GMSPlace *place in self.secondaryPlaces) {
        //[secondaries addObject:[NSString stringWithFormat:@"place_id:%@", place.placeID]];
        [secondaries addObject:place.name];
    }
    
    [DirectionsHelper plotDirectionsGivenStart:self.startPlace.name//[NSString stringWithFormat:@"place_id:%@", self.startPlace.placeID]
                                   destination:self.destinationPlace.name//[NSString stringWithFormat:@"place_id:%@", self.destinationPlace.placeID]
                                andSecondaryDestinations:secondaries
                                    onComplete:^(GMSPolyline *line, NSError *error) {
                                        self.mapLine.map = nil;
                                        self.mapLine = line;
                                        self.mapLine.map = self.mapView;
                                    }];
    
    // TODO animate to center of startPlace and endPlace
    [self.mapView animateToLocation:self.startPlace.coordinate];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.initialLocationSet) {
        [self.mapView animateToLocation:[locations lastObject].coordinate];
        self.initialLocationSet = true;
    }
}

- (void)directionsBtnClicked:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *searchViewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    
    // Allows this MapViewController to be notified of selections of locations
    searchViewController.delegate = self;
    
    NSMutableArray *secondaries = [NSMutableArray array];
    for (GMSPlace *place in self.secondaryPlaces) {
        [secondaries addObject:place.name];
    }
    [searchViewController setInitialRouteStart:self.startPlace.name end:self.destinationPlace.name andSecondaries:secondaries];
    
    self.secondaryMarkers = [NSMutableArray array];
    [self.navigationController pushViewController:searchViewController animated:YES];
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
            self.startMarker.map = self.mapView;
            self.startMarker.icon = [UIImage imageNamed:@"directionsMarker.png"];
            break;
        case SearchTypeDestination:
            self.destinationPlace = place;
            
            // Reset old marker
            self.endMarker.map = nil;
            
            self.endMarker = [[GMSMarker alloc] init];
            self.endMarker.position = self.destinationPlace.coordinate;
            self.endMarker.snippet = self.destinationPlace.formattedAddress;
            self.endMarker.appearAnimation = kGMSMarkerAnimationPop;
            self.endMarker.map = self.mapView;
            self.endMarker.icon = [UIImage imageNamed:@"directionsMarker.png"];
            break;
        case SearchTypeSecondary:
            self.currentSecondaryMarker = [[GMSMarker alloc] init];
            
            self.currentSecondaryMarker = [[GMSMarker alloc] init];
            self.currentSecondaryMarker.position = place.coordinate;
            self.currentSecondaryMarker.snippet = place.formattedAddress;
            self.currentSecondaryMarker.appearAnimation = kGMSMarkerAnimationPop;
            self.currentSecondaryMarker.map = self.mapView;
            self.currentSecondaryMarker.icon = [UIImage imageNamed:@"directionsMarker.png"];
            [self.secondaryMarkers addObject:self.currentSecondaryMarker];
            [self.secondaryPlaces addObject:place];
            break;
    }
}

@end