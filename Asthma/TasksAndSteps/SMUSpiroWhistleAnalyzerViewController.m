//
//  SMUSpiroWhistleAnalyzerViewController.m
//  Asthma
//
//  Created by Eric Larson on 5/27/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "SMUSpiroWhistleAnalyzerViewController.h"

@interface SMUSpiroWhistleAnalyzerViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *SpiroGraphicImageView;

@end

@implementation SMUSpiroWhistleAnalyzerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed: @"SpiroGraphic.png"];
    [[self SpiroGraphicImageView] setImage:image];
    
}


- (IBAction)testPressed:(id)sender {
    
    [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
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
