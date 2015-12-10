//
//  StopInputCell.m
//  RouteOptimizer
//
//  Created by  Minett on 12/9/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "StopInputCell.h"

float const kDefaultButtonWidth = 15;
float const kDefaultButtonLeading = 15;

@interface StopInputCell ()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConstraint;

@end

@implementation StopInputCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)editingChanged:(UITextField *)sender {
    [self.delegate stopDestinationSearchTextDidChange:sender];
}

- (IBAction)editingDidBegin:(UITextField *)sender {
    [self.delegate stopDestinationSearchTextDidBeginEditForTextField:sender inCell:self];
    [self.delegate stopDestinationDidBeginEditing:sender];
}

- (IBAction)editingDidEnd:(UITextField *)sender {
    [self.delegate stopDestinationDidEndEditing:sender];
}

- (IBAction)touchUpInsideRemoveButton:(UIButton *)sender {
    [self.delegate removeStopCell:self withTextField:self.stopTextField];
}

- (void)setupCellWithRemoveButton:(BOOL)withButton {
    if (withButton) {
        self.buttonLeadingConstraint.constant = kDefaultButtonLeading;
        self.buttonWidthConstraint.constant = kDefaultButtonWidth;
    } else {
        self.buttonLeadingConstraint.constant = 0;
        self.buttonWidthConstraint.constant = 0;
    }
}

@end
