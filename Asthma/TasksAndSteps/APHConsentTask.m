// 
//  APHConsentTask.m 
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
 
#import "APHConsentTask.h"
#import "APHAppDelegate.h"

static NSString *kReturnControlOfTaskDelegate = @"returnControlOfTaskDelegate";

@interface APHConsentTask ()
@property (strong, nonatomic) NSArray *steps;
@end

@implementation APHConsentTask
@synthesize steps = _steps;

-(id)initWithIdentifier:(NSString *)identifier steps:(NSArray *)steps{
    
    self = [super initWithIdentifier:identifier steps:steps];
    self.steps = steps;
    return self;
}

-(ORKStep *)stepBeforeStep:(ORKStep *)__unused step withResult:(ORKTaskResult *)__unused result{
    return nil;
}

-(ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)__unused result{
    
    APCUser *user = ((APHAppDelegate *)[UIApplication sharedApplication].delegate ).dataSubstrate.currentUser;
    ORKStep *nextStep;
    if (user.isSignedIn) {
        if (!step) {
            nextStep = [self.steps objectAtIndex:0];
        }else{
            nextStep = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kReturnControlOfTaskDelegate object:nil];
        }
    }else if(user.isSignedUp){
        if (!step) {
            nextStep = [self.steps objectAtIndex:0];
        }else{
            nextStep = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kReturnControlOfTaskDelegate object:nil];
        }
    }else{
        
        if (!step) {
            nextStep = [self.steps objectAtIndex:0];
        }else if ([step.identifier isEqualToString:@"consentStep"]) {
            nextStep = [self.steps objectAtIndex:1];
        }else if ([step.identifier isEqualToString:@"question1"]) {
            nextStep = [self.steps objectAtIndex:2];
        }else if ([step.identifier isEqualToString:@"question2"]) {
            nextStep = [self.steps objectAtIndex:3];
        }else if ([step.identifier isEqualToString:@"question3"]) {
            nextStep = [self.steps objectAtIndex:4];
        }else if ([step.identifier isEqualToString:@"quizEvaluation"]) {
            
            if (self.passedQuiz) {
                nextStep = [self.steps objectAtIndex:5];//return to consent review step
            }else if (self.failedAttempts == 1) {
                nextStep = [self.steps objectAtIndex:1];//return to quiz
            }else {
                nextStep = [self.steps objectAtIndex:0];//reassurance steps
            }
            
        }else if ([step isKindOfClass:[ORKConsentReviewStep class]]) {
            nextStep = step;
        }else{
            nextStep = nil;
        }
        
    }
    
    return nextStep;
}


@end
