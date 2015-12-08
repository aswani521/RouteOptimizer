//
//  SearchViewController.h
//  RouteOptimizer
//
//  Created by Aswani Nerella on 11/25/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

typedef NS_ENUM(NSInteger, SearchType) {
  SearchTypeOrigin = 0,
  SearchTypeDestination = 1,
  SearchTypeSecondary = 2
};

@protocol SearchViewControllerDelegate
- (void)completedSearchForPlace:(GMSPlace *)place withType:(enum SearchType) searchType;
- (void)autoCompleteSizeDidChange:(float)autocomleteHeight;

@end

@interface SearchViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) id <SearchViewControllerDelegate> delegate;
@property (strong, nonatomic) UICollectionView *searchResultCollectionView;

- (void)setInitialRouteStart:(NSString *)start end:(NSString *)end andSecondaries:(NSArray *)secondaries;
@end
