//
//  SMUSpiroInitialViewController.m
//  Asthma
//
//  Created by Eric Larson on 5/27/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "SMUSpiroInitialViewController.h"


@interface SMUSpiroInitialViewController ()
@property (strong, nonatomic) SpirometerEffortAnalyzer *spiro;

@end

@implementation SMUSpiroInitialViewController
- (IBAction)nextPressed:(id)sender {
    [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.spiro = [[SpirometerEffortAnalyzer alloc] init];
    self.spiro.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark SpirometerDelegate Methods



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
