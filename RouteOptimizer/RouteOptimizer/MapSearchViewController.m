//
//  MapSearchViewController.m
//  RouteOptimizer
//
//  Created by  Minett on 12/5/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "MapSearchViewController.h"
#import "MapSearchResultCell.h"
#import "DirectionsHelper.h"
#import "SearchPlaceModel.h"

@interface MapSearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightContsraint;
@property (strong, nonatomic) IBOutlet UICollectionView *searchResultsCollectionView;
@property (strong, nonatomic) IBOutlet UIView *baseMapView;

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSPolyline *mapLine;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSMutableArray *searchPlaces;

@end

@implementation MapSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Search Locations";
    
    self.searchResultsCollectionView.delegate = self;
    self.searchResultsCollectionView.dataSource = self;
    [self.searchResultsCollectionView registerNib:[UINib nibWithNibName:@"MapSearchResultCell" bundle:nil] forCellWithReuseIdentifier:@"MapSearchResultCell"];
    
    self.collectionViewHeightContsraint.constant = 0;
    [self.view layoutIfNeeded];
    
    // TODO come back to the initial setup of the camera for this view. If we have the location use it!
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.352011
                                                            longitude:-121.882324
                                                                 zoom:10];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    [self.mapView animateToLocation:self.mapView.myLocation.coordinate];
    //self.mapLine = [[GMSPolyline alloc] init];

    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    //marker.snippet = @"Hello World";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;

    self.baseMapView = self.mapView;
    
    // TODO animate to center of startPlace and endPlace
    //[self.mapView animateToLocation:self.startPlace.coordinate]
}

- (void)setSearchTerm:(NSString *)searchTerm {
    self.searchTerm = searchTerm;
    
    [DirectionsHelper placeSearchWithText:self.searchTerm onComplete:^(NSArray *places, NSError *error) {
        if (places) {
            for (NSDictionary *place in places) {
                SearchPlaceModel *searchPlace = [[SearchPlaceModel alloc] initWithDictionary:place];
                [self.searchPlaces addObject:searchPlace];
            }
            NSLog(@"%@", places);
            
            self.collectionViewHeightContsraint.constant = 300; // Don't know what to really do about this one to make it variable
        }
    }];
}

#pragma mark - UICollectionView delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchPlaces.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MapSearchResultCell *cell = [self.searchResultsCollectionView dequeueReusableCellWithReuseIdentifier:@"MapSearchResultCell" forIndexPath:indexPath];
    
    if (cell) {
        //
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.searchResultsCollectionView.frame.size.width, 50);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
