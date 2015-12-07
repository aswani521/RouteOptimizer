//
//  SearchResultCell.h
//  RouteOptimizer
//
//  Created by  Minett on 12/4/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface SearchResultCell : UICollectionViewCell
- (void)setupWithPlaceData:(GMSAutocompletePrediction *)placeData;
- (void)setupWithSearchData:(NSString *)searchTerm;

@end
