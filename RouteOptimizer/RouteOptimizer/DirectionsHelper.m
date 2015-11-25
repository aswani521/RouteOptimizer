//
//  DirectionsHelper.m
//  RouteOptimizer
//
//  Created by  Minett on 11/25/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "DirectionsHelper.h"
#import "AFNetworking.h"

NSString *const kAPIKey = @"AIzaSyBTSZYX4d4MNqYTEGmMpi7R4kCfLnnxbz4";
NSString *const kDirectionsBaseUrl = @"https://maps.googleapis.com/maps/api/directions/json";

@interface DirectionsHelper ()

@end

@implementation DirectionsHelper
+ (void)plotDirectionsGivenStart:(NSString *)start destination:(NSString *)end andSecondaryDestinations:(NSArray *)secondaryDestinations onComplete:(void (^)(GMSPolyline *line, NSError *error))completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSString *waypoints;
    NSString *directionsRequestUrl;
    NSString *origin = [start stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *destination = [end stringByReplacingOccurrencesOfString:@" " withString:@"+"];

    if (secondaryDestinations.count > 0) {
        waypoints = [NSString stringWithFormat:@"&waypoints=optimize:true|%@", [secondaryDestinations componentsJoinedByString:@"|"]];
        waypoints = [waypoints stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        waypoints = [waypoints stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        directionsRequestUrl = [NSString stringWithFormat:@"%@?origin=%@&destination=%@%@", kDirectionsBaseUrl, origin, destination, waypoints];
    } else {
        directionsRequestUrl = [NSString stringWithFormat:@"%@?origin=%@&destination=%@", kDirectionsBaseUrl, origin, destination];
    }

    [manager GET:directionsRequestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        GMSPolyline *polyline;
        NSString *encodedPath = responseObject[@"routes"][0][@"overview_polyline"][@"points"];
        if (encodedPath.length > 0) {
            GMSPath *path = [GMSPath pathFromEncodedPath:encodedPath];
            polyline = [GMSPolyline polylineWithPath:path];
            polyline.strokeWidth = 7;
            polyline.strokeColor = [UIColor purpleColor];
        }
        completion(polyline, nil);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
        NSLog(@"Error: %@", error);
    }];
}

@end
