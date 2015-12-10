//
//  StopInputViewcontroller.h
//  RouteOptimizer
//
//  Created by  Minett on 12/9/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopInputCell.h"

@protocol StopInputViewControllerDelegate

- (void)removeStopWithFormattedAddress:(NSString *)formattedAddress;

@end
@interface StopInputViewcontroller : UIViewController
- (void)didCompleteSelectionForPlaceWithAddress:(NSString *)formattedAddress;
@property (nonatomic, weak) id<StopInputCellDelegate, StopInputViewControllerDelegate> delegate;
@end
