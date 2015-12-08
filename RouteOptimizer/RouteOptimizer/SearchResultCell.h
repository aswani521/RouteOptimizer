//
//  SearchResultCell.h
//  RouteOptimizer
//
//  Created by  Minett on 12/4/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchPlaceModel.h"
@import GoogleMaps;

@protocol SearchResultCellDelegate
- (void)detailsWasTouchedForPlace:(NSString *)placeIdentifier;

@end

@interface SearchResultCell : UICollectionViewCell
@property (nonatomic, strong) id delegate;
- (void)setupWithPlaceData:(GMSAutocompletePrediction *)placeData;
- (void)setupWithSearchPlaceData:(SearchPlaceModel *)placeData;
//- (void)setupWithSearchPlaceData:(SearchPlaceModel *)placeData;
- (void)setupWithSearchData:(NSString *)searchTerm;

@end
