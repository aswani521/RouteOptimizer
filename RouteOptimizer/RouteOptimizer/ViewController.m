//
//  ViewController.m
//  RouteOptimizer
//
//  Created by  Minett on 11/19/15.
//  Copyright © 2015  Minett. All rights reserved.
//

@import GoogleMaps;
#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                          longitude:151.2086
                                                               zoom:6];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];

  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.position = camera.target;
  marker.snippet = @"Hello World";
  marker.appearAnimation = kGMSMarkerAnimationPop;
  marker.map = mapView;

  self.view = mapView;
}

@end