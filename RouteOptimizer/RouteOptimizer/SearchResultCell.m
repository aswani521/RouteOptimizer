//
//  SearchResultCell.m
//  RouteOptimizer
//
//  Created by  Minett on 12/4/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "SearchResultCell.h"

@interface SearchResultCell ()
@property (strong, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *placeNameSecondaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripDurationAdditionLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceAdditionLabel;

@property (strong, nonatomic) SearchPlaceModel *searchPlaceModel;
@property (strong, nonatomic) GMSAutocompletePrediction *autocompletePrediction;

@end

@implementation SearchResultCell

- (void)awakeFromNib {
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)setupWithPlaceData:(GMSAutocompletePrediction *)placeData {
    self.autocompletePrediction = placeData;
    //UIFont *regularFont = self.placeNameLabel.font;
    UIFont *regularFont = [UIFont systemFontOfSize:self.placeNameLabel.font.pointSize];
    //UIFont *boldFont = [UIFont fontWithDescriptor:[[regularFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:regularFont.pointSize];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:regularFont.pointSize];
    
    NSMutableAttributedString *bolded = [placeData.attributedPrimaryText mutableCopy];
    [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
                       inRange:NSMakeRange(0, bolded.length)
                       options:0
                    usingBlock:^(id value, NSRange range, BOOL *stop) {
                        UIFont *font = (value == nil) ? regularFont : boldFont;
                        [bolded addAttribute:NSFontAttributeName value:font range:range];
                    }];
    
    self.tripDurationAdditionLabel.text = @"";
    self.distanceAdditionLabel.text = @"";
    self.placeNameLabel.attributedText = bolded;
    self.placeNameSecondaryLabel.attributedText = placeData.attributedFullText;
}

- (void)setupWithPlaceData:(GMSAutocompletePrediction *)placeData existingDirections:(DirectionsModel *)existingDirections andNewDirections:(DirectionsModel *)newDirections {
    [self setupWithPlaceData:placeData];
    
    if (existingDirections && newDirections) {
        float durationDifference = newDirections.durationInMinutes - existingDirections.durationInMinutes;
        float distanceDifference = newDirections.distanceInMiles - existingDirections.distanceInMiles;
        self.tripDurationAdditionLabel.text = [NSString stringWithFormat:@"%+0.1f MINS", durationDifference];
        self.distanceAdditionLabel.text = [NSString stringWithFormat:@"%+0.2f mi", distanceDifference];
    }
}

- (void)setupWithSearchData:(NSString *)searchTerm {
    self.tripDurationAdditionLabel.text = @"";
    self.distanceAdditionLabel.text = @"";
    self.placeNameLabel.text = searchTerm;
}

- (void)setupWithSearchPlaceData:(SearchPlaceModel *)placeData {
    self.searchPlaceModel = placeData;
}

- (IBAction)touchUpOnMerchantShow:(UIButton *)sender {
    [self.delegate detailsWasTouchedForPlace:[self.autocompletePrediction.attributedFullText string]];
}

@end
