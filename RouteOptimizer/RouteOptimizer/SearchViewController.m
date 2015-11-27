//
//  SearchViewController.m
//  RouteOptimizer
//
//  Created by Aswani Nerella on 11/25/15.
//  Copyright © 2015  Minett. All rights reserved.
//

#import "SearchViewController.h"
#import "ViewController.h"

@interface SearchViewController ()
@property (strong, nonatomic) IBOutlet UITextField *startAddress;
@property (strong, nonatomic) IBOutlet UITextField *endAddress;
@property (strong, nonatomic) IBOutlet UITextField *searchTerm;

@end

@implementation SearchViewController
- (IBAction)findRouteButtonClicked:(id)sender {
    
    NSLog(@"Start location:  %@",self.startAddress.text);
    NSLog(@"End location: %@",self.endAddress.text);
    
    //Move to the other view
    
    ViewController *mapViewController = [[ViewController alloc]init];
    mapViewController.startAddress = self.startAddress.text;
    mapViewController.endAddress = self.endAddress.text;
    
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:mapViewController];
    [self presentViewController:nvc animated:YES completion:nil];
    
    
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
