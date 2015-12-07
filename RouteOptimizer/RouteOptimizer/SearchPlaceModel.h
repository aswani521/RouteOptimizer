//
//  SearchPlaceModel.h
//  RouteOptimizer
//
//  Created by  Minett on 12/5/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

@interface SearchPlaceModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *placeId;
//@property (nonatomic, strong) NSString *phoneNumber;
//@property (nonatomic, strong) NSString *formatedAddress;
@property (nonatomic, strong) NSString *iconImageString;
//@property (nonatomic, strong) NSString *website;
@property (nonatomic, assign) float rating;
//@property (nonatomic, assign) float priceLevel;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, copy) NSArray *photos;
@property (nonatomic, copy) NSArray *types;
@property (nonatomic, strong) NSDictionary *openNowStatus;
//@property (nonatomic, assign) GMSCoordinateBounds *viewport; // May not be present
@property (nonatomic, strong) GMSPlace *place;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
