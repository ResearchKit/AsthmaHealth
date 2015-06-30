// 
//  APHEnrollmentForRecontactTaskViewController.m 
//  Asthma 
// 
// Copyright (c) 2015, Icahn School of Medicine at Mount Sinai. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APHEnrollmentForRecontactTaskViewController.h"
#import "APHEnrollmentIntroduction.h"

static  NSString  *kEnrollmentRecontact101 = @"enrollmentRecontact101";

@interface APHEnrollmentForRecontactTaskViewController ()

@end

@implementation APHEnrollmentForRecontactTaskViewController

/*********************************************************************************/
#pragma  mark  -  Task Creation Methods
/*********************************************************************************/

+ (ORKOrderedTask *)createTask:(APCScheduledTask *)__unused scheduledTask
{
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    {
        ORKStep *step = [[ORKStep alloc] initWithIdentifier:kEnrollmentRecontact101];
        
        [steps addObject:step];
    }
        
    //The identifier gets set as the title in the navigation bar.
    ORKOrderedTask  *task = [[ORKOrderedTask alloc] initWithIdentifier:@"Journal" steps:steps];
    
    return  task;
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (ORKStepViewController *)taskViewController:(ORKTaskViewController *)__unused taskViewController viewControllerForStep:(ORKStep *)step {
    
    NSDictionary  *controllers = @{kEnrollmentRecontact101 : @"APHEnrollmentIntroduction"};
    
    APCStepViewController  *controller = nil;
    
    if ( step.identifier == kEnrollmentRecontact101) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:[controllers objectForKey:step.identifier]
                                                                 bundle:nil];
        
        controller = [mainStoryboard instantiateViewControllerWithIdentifier:[controllers objectForKey:step.identifier]];
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
            [super taskViewController:self didFinishWithReason:reason error:error];
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
