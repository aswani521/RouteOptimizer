//
//  StopInputViewcontroller.m
//  RouteOptimizer
//
//  Created by  Minett on 12/9/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "StopInputViewcontroller.h"

@interface StopInputViewcontroller () <UICollectionViewDataSource, UICollectionViewDelegate, StopInputCellDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *stopInputCollection;

@property (nonatomic, strong) NSMutableDictionary *currentStopDestinations;
@property (nonatomic, strong) NSIndexPath *currentCellIndexPath;

@end

@implementation StopInputViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stopInputCollection.delegate = self;
    self.stopInputCollection.dataSource = self;
    [self.stopInputCollection registerNib:[UINib nibWithNibName:@"StopInputCell" bundle:nil] forCellWithReuseIdentifier:@"StopInputCell"];
    
    self.currentStopDestinations = [NSMutableDictionary dictionary];
}

- (void)didCompleteSelectionForPlaceWithAddress:(NSString *)formattedAddress {
    NSString *existingAddress = [[self.currentStopDestinations allKeysForObject:@(self.currentCellIndexPath.row)] firstObject];
    if (existingAddress) {
        [self.currentStopDestinations removeObjectForKey:existingAddress];
        [self.delegate removeStopWithFormattedAddress:existingAddress];
    }
    self.currentStopDestinations[formattedAddress] = @(self.currentCellIndexPath.row);
    [self.stopInputCollection reloadData];
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:self.currentStopDestinations.count inSection:0];
    [self.stopInputCollection scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

# pragma mark - UICollectionViewDataSource delegate methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //return 2;
    return self.currentStopDestinations.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StopInputCell *cell = [self.stopInputCollection dequeueReusableCellWithReuseIdentifier:@"StopInputCell" forIndexPath:indexPath];
    
    if (cell) {
        cell.stopTextField.text = @"";
        cell.delegate = self;
        
        if (self.currentStopDestinations.count > 0) {
            cell.stopTextField.text = [[self.currentStopDestinations allKeysForObject:@(indexPath.row)] firstObject];
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.stopInputCollection.frame.size.width - 60, 50); // Will not be size 50
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    self.currentCellIndexPath = indexPath;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item (Not needed just yet)
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    // The motions happen so fast that this is not relly showing. Maybe it'll show if we animate
    //MapSearchResultCell *cell = (MapSearchResultCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //[cell setHighlighted:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    // The motions happen so fast that this is not relly showing. Maybe it'll show if we animate
    //MapSearchResultCell *cell = (MapSearchResultCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //[cell setHighlighted:NO];
}

- (void)stopDestinationDidBeginEditing:(UITextField *)textField {
    [self.delegate stopDestinationDidBeginEditing:textField];
}

- (void)stopDestinationDidEndEditing:(UITextField *)textField {
    [self.delegate stopDestinationDidEndEditing:textField];
}

- (void)stopDestinationSearchTextDidChange:(UITextField *)textField {
    [self.delegate stopDestinationSearchTextDidChange:textField];
}

- (void)stopDestinationSearchTextDidBeginEditForTextField:(UITextField *)textField inCell:(StopInputCell *)cell {
    NSIndexPath *indexPath = [self.stopInputCollection indexPathForCell:cell];
    [self collectionView:self.stopInputCollection didSelectItemAtIndexPath:indexPath];
}

- (void)removeStopCell:(StopInputCell *)cell withTextField:(UITextField *)textField {
    NSIndexPath *indexPath = [self.stopInputCollection indexPathForCell:cell];
    NSString *existingAddress = [[self.currentStopDestinations allKeysForObject:@(indexPath.row)] firstObject];
    if (existingAddress) {
        [self.currentStopDestinations removeObjectForKey:existingAddress];
        [self.delegate removeStopWithFormattedAddress:existingAddress];
    }
    [self.stopInputCollection reloadData];
    
    //NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:self.currentStopDestinations.count inSection:0];
    //[self.stopInputCollection scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

@end
