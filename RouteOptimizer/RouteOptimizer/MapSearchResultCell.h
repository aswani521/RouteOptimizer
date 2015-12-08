//
//  MapSearchResultCell.h
//  RouteOptimizer
//
//  Created by  Minett on 12/5/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchPlaceModel.h"

@interface MapSearchResultCell : UICollectionViewCell
- (void)setupCellWithSearchPlaceData:(SearchPlaceModel *)searchPlace;

@end
