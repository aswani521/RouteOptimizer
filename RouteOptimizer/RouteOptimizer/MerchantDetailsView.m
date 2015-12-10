//
//  MerchantDetailsView.m
//  RouteOptimizer
//
//  Created by Aswani Nerella on 12/6/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "MerchantDetailsView.h"
#import "SearchPlaceModel.h"
#import "UIImageView+AFNetworking.h"
#import <MapKit/MapKit.h>

NSString *const kPhotosBaseUrl= @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=124&maxwidth=117&key=AIzaSyBkWxCqBKj6rtN84UAAbYOhqDysodnAdAA&maxheight=400&photoreference=";
//// original image request
//https://maps.googleapis.com/maps/api/place/photo?maxwidth=124&maxwidth=117&key=AIzaSyBkWxCqBKj6rtN84UAAbYOhqDysodnAdAA&maxheight=400&photoreference=CmRdAAAA1ttOe3UysDPTKeFd2xwc4zrnd7Cdj0EvRRSz17tdmx2P7oJotMzJR-93o5Ub2cbe3XVnEVsdFWo1Dgb-3Bm6LAHia0jmkvIX0LbldhX9p3R3Sc_oivA0lZkC19_2U-ohEhCE9B0HFnst9ixHnHqu0rHeGhQPybgHRiIhslEg7cbRqgAmLRTGxA

@interface MerchantDetailsView () <SearchPlaceModelDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *MerchantMapView;
@property (strong, nonatomic) IBOutlet UILabel *MerchantAddressLine1;
@property (strong, nonatomic) IBOutlet UILabel *MerchantAddressLine2;
@property (strong, nonatomic) IBOutlet UILabel *MerchantBusinessOpenHoursMessage;
@property (strong, nonatomic) IBOutlet UILabel *MerchantPhoneNumber;
@property (strong, nonatomic) IBOutlet UIImageView *MerchantBusinessImg1;
@property (strong, nonatomic) IBOutlet UIImageView *MerchantBusinessImg2;
@property (strong, nonatomic) IBOutlet UITextView *PhoneTextView;

@end

@implementation MerchantDetailsView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.MerchantPlace.delegate = self;
    [self setPlaces:self.MerchantPlace];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchPlaceModel:(SearchPlaceModel *)model didCompleteLoadWithPlace:(GMSPlace *)place {
    // May want to just set the needed fields instead of a complete reset
    [self setPlaces:self.MerchantPlace];
}

- (NSURL*) generatePhotoImgNSUrlUsingPhotoReference:(NSString*) photoReference{
    NSString *photo_reference = photoReference;//[self.MerchantPlace.photos[0] objectForKey:@"photo_reference"];
    NSString *imageUrlString = [NSString stringWithFormat:@"%@%@",kPhotosBaseUrl,photo_reference];
    NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
    return imageUrl;
}

- (void) setPlaces:(SearchPlaceModel *)MerchantPlace{
    _MerchantPlace = MerchantPlace;
    self.MerchantAddressLine1.text = self.MerchantPlace.name;

    // Fix me
    self.MerchantAddressLine2.text = self.MerchantPlace.place.formattedAddress;


    if ([self.MerchantPlace.openNowStatus objectForKey:@"open_now"]>0) {
        self.MerchantBusinessOpenHoursMessage.text = @"Business: Open Now";
    }
    else{
        self.MerchantBusinessOpenHoursMessage.text = @"Business: is Closed";
    }
//    self.MerchantPhoneNumber.text = self.MerchantPlace.place.phoneNumber;
    if (self.MerchantPlace.place != nil) {
        self.PhoneTextView.text = self.MerchantPlace.place.phoneNumber;
        self.PhoneTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        self.PhoneTextView.editable = NO;
    }
    
    if (self.MerchantPlace.photos.count>0) {
        [ self.MerchantBusinessImg1 setImageWithURL:[self generatePhotoImgNSUrlUsingPhotoReference:[self.MerchantPlace.photos[0] objectForKey:@"photo_reference"]] ];
    }
    if (self.MerchantPlace.photos.count>1) {
        [ self.MerchantBusinessImg2 setImageWithURL:[self generatePhotoImgNSUrlUsingPhotoReference:[self.MerchantPlace.photos[1] objectForKey:@"photo_reference"]] ];
    }

//    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),MKCoordinateSpanMake(0.1, 0.1));
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(self.MerchantPlace.location, MKCoordinateSpanMake(0.01,0.01));
//    NSLog(@"location lat lng: %@",self.MerchantPlace.location);
    [self.MerchantMapView setRegion:mapRegion animated:NO];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:self.MerchantPlace.location];
    [self.MerchantMapView addAnnotation:annotation];
    self.MerchantMapView.zoomEnabled = YES;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
