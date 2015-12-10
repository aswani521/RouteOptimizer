//
//  SearchViewController.h
//  RouteOptimizer
//
//  Created by Aswani Nerella on 11/25/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchPlaceModel.h"
#import "DirectionsModel.h"
#import "StopInputCell.h"
#import "StopInputViewcontroller.h"
@import GoogleMaps;

typedef NS_ENUM(NSInteger, SearchType) {
  SearchTypeOrigin = 0,
  SearchTypeDestination = 1,
  SearchTypeSecondary = 2
};

@protocol SearchViewControllerDelegate
- (void)completedSearchForPlace:(GMSPlace *)place withType:(enum SearchType) searchType;
- (void)completedFullSearchWithResults:(NSArray *)searchPlaces;
- (void)autoCompleteSizeDidChange:(float)autocomleteHeight;
- (void)detailsTouchedForPlaceIdentifier:(NSString *)placeIdentifier;

@end

@interface SearchViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, StopInputCellDelegate, StopInputViewControllerDelegate>
@property (nonatomic, strong) id <SearchViewControllerDelegate, StopInputViewControllerDelegate> delegate;
@property (strong, nonatomic) UICollectionView *searchResultCollectionView;

- (void)setInitialRouteStart:(NSString *)start end:(NSString *)end andSecondaries:(NSArray *)secondaries;
- (void)setCurrentDirectionsModel:(nullable DirectionsModel *)directionsModel;
- (void)stopDestinationDidBeginEditing:(UITextField *)textField;
- (void)stopDestinationDidEndEditing:(UITextField *)textField;
- (void)stopDestinationSearchTextDidChange:(UITextField *)textField;
- (void)animateStopsInputOpen;

@end
