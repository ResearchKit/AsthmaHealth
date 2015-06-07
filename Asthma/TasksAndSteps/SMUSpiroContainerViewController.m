//
//  SMUSpiroContainerViewController.m
//  Asthma
//
//  Created by Eric Larson on 5/27/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "SMUSpiroContainerViewController.h"

@interface SMUSpiroContainerViewController ()

@property (nonatomic, strong) ORKStepResult *cachedResult;

@property (weak, nonatomic) IBOutlet UIButton *nextSubmitButton;
@end

@implementation SMUSpiroContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (ORKStepResult *)result {
    
    if (!self.cachedResult) {
        self.cachedResult = [[ORKStepResult alloc] initWithIdentifier:self.step.identifier];
    }
    
    return self.cachedResult;
}


@end
