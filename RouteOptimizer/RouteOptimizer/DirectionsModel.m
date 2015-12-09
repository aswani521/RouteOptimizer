//
//  DirectionsModel.m
//  RouteOptimizer
//
//  Created by  Minett on 12/8/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "DirectionsModel.h"
@import GoogleMaps;

@implementation DirectionsModel
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        GMSPolyline *polyline;
        NSString *encodedPath;
        NSArray *routes = dictionary[@"routes"];
        NSArray *legs;
        NSDictionary *bounds;
        
        if (routes.count > 0) {
            encodedPath = routes[0][@"overview_polyline"][@"points"];
            legs = routes[0][@"legs"];
            bounds = routes[0][@"bounds"];
            self.summary = routes[0][@"summary"];
        }
        
        if (legs.count > 0) {
            self.distanceInMeters = 0;
            self.distanceInMiles = 0;
            self.durationInSeconds = 0;
            self.durationInMinutes = 0;
            
            for (NSDictionary *leg in legs) {
                self.distanceInMeters += [[leg[@"distance"] objectForKey:@"value"] floatValue];
                
                self.durationInSeconds += [[leg[@"duration"] objectForKey:@"value"] floatValue];
            }
            
            self.distanceInMiles += self.distanceInMeters * 0.000621371192;
            self.durationInMinutes += self.durationInSeconds / 60;
            self.durationText = [NSString stringWithFormat:@"%0.1f MINS", self.durationInMinutes];
            self.distanceText = [NSString stringWithFormat:@"%0.2f mi", self.distanceInMiles];
            self.startAddress = [legs firstObject][@"start_address"];
            self.endAddress = [legs lastObject][@"end_address"];
        }
        
        if (bounds.count > 0) {
            NSDictionary *neBounds = bounds[@"northeast"];
            NSDictionary *swBounds = bounds[@"southwest"];
            CLLocationDegrees nlat = [[neBounds objectForKey:@"lat"] doubleValue];
            CLLocationDegrees nlng = [[neBounds objectForKey:@"lng"] doubleValue];
            CLLocationDegrees slat = [[swBounds objectForKey:@"lat"] doubleValue];
            CLLocationDegrees slng = [[swBounds objectForKey:@"lng"] doubleValue];
            self.northeastBound = CLLocationCoordinate2DMake(nlat, nlng);
            self.southwestBound = CLLocationCoordinate2DMake(slat, slng);
        }
        
        if (encodedPath.length > 0) {
            GMSPath *path = [GMSPath pathFromEncodedPath:encodedPath];
            polyline = [GMSPolyline polylineWithPath:path];
            polyline.strokeWidth = 7;
            polyline.strokeColor = [UIColor blueColor];
        }
        
        self.mapLine = polyline;
    }
    return self;
}

@end
