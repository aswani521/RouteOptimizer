//
//  DirectionsModel.h
//  RouteOptimizer
//
//  Created by  Minett on 12/8/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;

@interface DirectionsModel : NSObject
- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, assign) CLLocationCoordinate2D northeastBound;
@property (nonatomic, assign) CLLocationCoordinate2D southwestBound;
@property (nonatomic, strong) NSString *startAddress;
@property (nonatomic, strong) NSString *endAddress;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *durationText;
@property (nonatomic, strong) NSString *distanceText;
@property (nonatomic, assign) float durationInSeconds;
@property (nonatomic, assign) float durationInMinutes;
@property (nonatomic, assign) float distanceInMeters;
@property (nonatomic, assign) float distanceInMiles;
@property (nonatomic, strong) GMSPolyline *mapLine;

@end
