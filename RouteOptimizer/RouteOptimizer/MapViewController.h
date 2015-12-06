//
//  ViewController.h
//  RouteOptimizer
//
//  Created by  Minett on 11/19/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface MapViewController : UIViewController
@property (nonatomic,strong) GMSPlace *startPlace;
@property (nonatomic,strong) GMSPlace *destinationPlace;
@property (nonatomic,strong) NSMutableArray *secondaryPlaces;

@end

