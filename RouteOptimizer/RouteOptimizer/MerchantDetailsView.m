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

@interface MerchantDetailsView ()
@property (strong, nonatomic) IBOutlet GMSMapView *MerchantMapView;
@property (strong, nonatomic) IBOutlet UILabel *MerchantAddressLine1;
@property (strong, nonatomic) IBOutlet UILabel *MerchantAddressLine2;
@property (strong, nonatomic) IBOutlet UILabel *MerchantBusinessOpenHoursMessage;
@property (strong, nonatomic) IBOutlet UILabel *MerchantPhoneNumber;
@property (strong, nonatomic) IBOutlet UIImageView *MerchantBusinessImg1;
@property (strong, nonatomic) IBOutlet UIImageView *MerchantBusinessImg2;

@end

@implementation MerchantDetailsView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setPlaces:self.MerchantPlace];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setPlaces:(SearchPlaceModel *)MerchantPlace{
    _MerchantPlace = MerchantPlace;
    self.MerchantAddressLine1.text = @"Hyderabad";
    
    //self.MerchantAddressLine1.text = self.MerchantPlace.name;
    // Fix me
//    self.MerchantAddressLine2.text = self.MerchantPlace.formattedAddress;
//    self.MerchantMapView = self.place; // add the right one here
//    self.MerchantBusinessOpenHoursMessage = self.MerchantPlace.openNowStatus; // add the correct one here
//    self.MerchantPhoneNumber.text = self.MerchantPlace.phoneNumber;
    [ self.MerchantBusinessImg1 setImageWithURL:self.MerchantPlace.photos[0]];
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
