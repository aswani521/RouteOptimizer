//
//  ViewController.m
//  RouteOptimizer
//
//  Created by  Minett on 11/19/15.
//  Copyright © 2015  Minett. All rights reserved.
//

@import GoogleMaps;
#import "ViewController.h"
#import "DirectionsHelper.h"

@interface ViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) GMSPlacePicker *placePicker;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, assign) BOOL initialLocationSet;
@property (nonatomic, strong) CLLocationManager *locationManager;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.352011
                                                            longitude:-121.882324
                                                                 zoom:10];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    [self.mapView animateToLocation:self.mapView.myLocation.coordinate];

    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.snippet = @"Hello World";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;

    self.view = self.mapView;

    // Just an example of how direction plotting should work
//    [DirectionsHelper plotDirectionsGivenStart:@"San Francisco, CA"
//                                   destination:@"Milpitas, CA"
//                      andSecondaryDestinations:@[@"Santa Cruz, CA", @"Pacifica, CA"]
//                                    onComplete:^(GMSPolyline *line, NSError *error) {
//                                        line.map = self.mapView;
//                                        NSLog(@"%@", line);
//                                        NSLog(@"%@", error);
//    }];
    
    NSLog(@"Start Address: %@ End Address: %@",self.startAddress, self.endAddress);
    [DirectionsHelper plotDirectionsGivenStart:self.startAddress
                                   destination:self.endAddress
                                andSecondaryDestinations:@[]
                                    onComplete:^(GMSPolyline *line, NSError *error) {
                                        line.map = self.mapView;
                                        NSLog(@"%@", line);
                                        NSLog(@"%@", error);
                                    }];
}

// The code snippet below shows how to create a GMSPlacePicker
// centered on Sydney, and output details of a selected place.
- (IBAction)pickPlace:(UIButton *)sender {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(37.352011, -121.882324);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    self.placePicker = [[GMSPlacePicker alloc] initWithConfig:config];

    [self.placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }

        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place attributions %@", place.attributions.string);
        } else {
            NSLog(@"No place selected");
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.initialLocationSet) {
        [self.mapView animateToLocation:[locations lastObject].coordinate];
        self.initialLocationSet = true;
    }
}

@end