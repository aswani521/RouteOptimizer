//
//  StopInputCell.h
//  RouteOptimizer
//
//  Created by  Minett on 12/9/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StopInputCell;

@protocol StopInputCellDelegate
- (void)stopDestinationDidBeginEditing:(UITextField *)textField;
- (void)stopDestinationDidEndEditing:(UITextField *)textField;
- (void)stopDestinationSearchTextDidChange:(UITextField *)textField;

@optional
- (void)stopDestinationSearchTextDidBeginEditForTextField:(UITextField *)textField inCell:(StopInputCell *)cell;
- (void)removeStopCell:(StopInputCell *)cell withTextField:(UITextField *)textField;

@end

@interface StopInputCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UITextField *stopTextField;
@property (nonatomic, weak) id delegate;

- (void)setupCellWithRemoveButton:(BOOL)withButton;

@end
