//
//  SearchPlaceModel.m
//  RouteOptimizer
//
//  Created by  Minett on 12/5/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "SearchPlaceModel.h"

@implementation SearchPlaceModel

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        // street address
        self.placeId = dictionary[@"place_id"];
        self.rating = [[dictionary objectForKey:@"rating"] floatValue];
        self.iconImageString = dictionary[@"icon"];
        self.photos = dictionary[@"photos"];
        self.types = dictionary[@"types"];
        self.openNowStatus = dictionary[@"opening_hours"];
        
        // phone number
        
        NSDictionary *geometry = dictionary[@"geometry"];
        if (geometry) {
            if (geometry[@"location"]) {
                CLLocationDegrees lat = [[geometry[@"location"] objectForKey:@"lat"] integerValue];
                CLLocationDegrees lng = [[geometry[@"location"] objectForKey:@"lng"] integerValue];
                self.location = CLLocationCoordinate2DMake(lat, lng);
            }
            
        }
        
        //Make a remote call to fetch the place if we need it
        GMSPlacesClient *placesClient = [[GMSPlacesClient alloc] init];
        [placesClient lookUpPlaceID:self.placeId callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
            if (result) {
                self.place = result;
            }
        }];
    }
    return self;
}

@end
