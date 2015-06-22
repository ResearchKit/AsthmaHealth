//
//  SMUSpiroTestTaskViewController.m
//  Asthma
//
//  Created by Eric Larson on 5/26/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "SMUSpiroTestTaskViewController.h"
#import "SMUSpiroWhistleAnalyzerViewController.h"

static  NSString  *kLungFunctionTest = @"lungFunctionTest";
static  NSString  *kLungFunctionInit = @"lungFunctionInit";
static  NSString  *kLungFunctionCompletion = @"lungFunctionCompletion";


@interface SMUSpiroTestTaskViewController ()

@end

@implementation SMUSpiroTestTaskViewController

/*********************************************************************************/
#pragma  mark  -  Task Creation Methods
/*********************************************************************************/

+ (ORKOrderedTask *)createTask:(APCScheduledTask *)__unused scheduledTask
{
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    {
        ORKStep *step = [[ORKStep alloc] initWithIdentifier:kLungFunctionTest];

        [steps addObject:step];
        
        ORKStep *step2 = [[ORKStep alloc] initWithIdentifier:kLungFunctionInit];
        [steps addObject:step2];
        
        ORKStep *step3 = [[ORKStep alloc] initWithIdentifier:kLungFunctionCompletion];
        [steps addObject:step3];
    }
    
    //The identifier gets set as the title in the navigation bar.
    ORKOrderedTask  *task = [[ORKOrderedTask alloc] initWithIdentifier:@"Spirometry Test" steps:steps];
    
    return  task;
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (ORKStepViewController *)taskViewController:(ORKTaskViewController *)__unused taskViewController viewControllerForStep:(ORKStep *)step {
    
    NSDictionary  *controllers = @{kLungFunctionTest : @[@"SMUSpiroStoryboard",
                                                         @"SMUSpiroWhistleAnalyzerViewController"],
                                   kLungFunctionInit : @[@"SMUSpiroStoryboard",
                                                         @"SMUSpiroInitialViewController"],
                                   kLungFunctionCompletion :
                                       @[@"SMUSpiroStoryboard",
                                         @"SMUSpiroCompletionViewController"]};
    
    
    
    APCStepViewController  *controller = nil;
    
    if ( step.identifier == kLungFunctionTest || step.identifier == kLungFunctionInit || step.identifier == kLungFunctionCompletion) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:[controllers objectForKey:step.identifier][0]
                                                                 bundle:nil];
        
        controller = [mainStoryboard instantiateViewControllerWithIdentifier:[controllers objectForKey:step.identifier][1]];
    }
    
    controller.delegate = self;
    controller.step = step;
    
    return controller;
}

- (void) taskViewController: (ORKTaskViewController * __nonnull) taskViewController
        didFinishWithReason: (ORKTaskViewControllerFinishReason) reason
                      error: (nullable NSError *) error
{
    switch (reason)
    {
        case ORKTaskViewControllerFinishReasonSaved:
            break;
            
        case ORKTaskViewControllerFinishReasonDiscarded:
            break;
            
        case ORKTaskViewControllerFinishReasonCompleted:
            break;
            
        case ORKTaskViewControllerFinishReasonFailed:
            break;
            
        default:
            break;
    }
    
    [super taskViewController:taskViewController didFinishWithReason:reason error:error];
}

-(void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction{
    
    [super stepViewController:stepViewController didFinishWithNavigationDirection:direction];
}


@end
