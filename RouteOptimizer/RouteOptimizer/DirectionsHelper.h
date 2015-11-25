//
//  DirectionsHelper.h
//  RouteOptimizer
//
//  Created by  Minett on 11/25/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

@interface DirectionsHelper : NSObject
/**
 *  Will return the Polyline path of directions to plot on a map
 *
 *  @param start                 where the path should begin - Format string address, string lat/long pair, string place_id:actual_location_place_id
 *  @param end                   where the path should end - Format string address, string lat/long pair, string place_id:actual_location_place_id
 *  @param secondaryDestinations an array of secondary destinations to be plotted in the path. The path route will be optimized based on these values. This param can range from 0 - ~20 elements
 *  @param completion a block that expects a GMSPloyline * and/or and NSError *. Upon calculation of the directions this block will be called
 *
 */
+ (void)plotDirectionsGivenStart:(NSString *)start destination:(NSString *)end andSecondaryDestinations:(NSArray *)secondaryDestinations onComplete:(void (^)(GMSPolyline *line, NSError *error))completion;

@end
