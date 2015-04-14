// 
//  APHConsentTaskViewController.m 
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
 
#import "APHConsentTaskViewController.h"
#import "APHQuizStepViewController.h"
#import "APHQuizEvaluationViewController.h"
#import "APHBooleanQuestionStep.h"
#import "APHConsentTask.h"
#import "APHConsentRedirector.h"


static NSString *kReturnControlOfTaskDelegate = @"returnControlOfTaskDelegate";

@interface APHConsentTaskViewController ()
@property (nonatomic, strong) NSMutableDictionary *resultsDictionary;
@property (nonatomic, assign) BOOL passedTest;
@property (weak, nonatomic) ORKStep *signatureStep;//save the signature step to show later

@property (nonatomic, assign) NSUInteger    failedAttempts;

@end

@implementation APHConsentTaskViewController 

static const int numberOfQuestions = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.failedAttempts = 0;
    self.showsProgressInNavigationBar = NO;
    self.resultsDictionary = [[NSMutableDictionary alloc]initWithCapacity:numberOfQuestions];
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TaskViewController Delegate

- (void) taskViewController: (ORKTaskViewController * __nonnull) __unused taskViewController
        didFinishWithReason: (ORKTaskViewControllerFinishReason) reason
                      error: (nullable NSError *) error
{
    APCLogDebug(@"APHConsentTaskViewController didFinishWithReason %li", reason);

    [super taskViewController: self
          didFinishWithReason: reason
                        error: error];

    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * @brief Supply a custom view controller for a given step.
 * @discussion The delegate should provide a step view controller implementation for any custom step.
 * @return A custom view controller, or nil to use the default step controller for this step.
 */
- (ORKStepViewController *)taskViewController:(ORKTaskViewController *) __unused taskViewController viewControllerForStep:(ORKStep *)step{
        
    if ([step isKindOfClass:[APHBooleanQuestionStep class]]) {
        APHQuizStepViewController *questionStepViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"APHQuizStepViewController"];
                
        questionStepViewController.step = step;
        questionStepViewController.delegate = self;
        return questionStepViewController;

    }
    
    if ([step.identifier isEqualToString:@"quizEvaluation"]) {
        APHQuizEvaluationViewController *quizEvaluation = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"APHQuizEvaluationViewController"];
        quizEvaluation.step = step;
        quizEvaluation.delegate = self;
        quizEvaluation.passedQuiz = self.passedTest;
        quizEvaluation.failedAttempts = self.failedAttempts;
        return quizEvaluation;
    }
    
    return nil;
}

/**
 * @brief Control whether the task controller proceeds to the next or previous step.
 * @return YES, if navigation can proceed to the specified step.
 */
- (BOOL)taskViewController:(ORKTaskViewController *)__unused taskViewController shouldPresentStep:(ORKStep *)step{
    
    self.correctCount = 0;
    if ([step.identifier isEqualToString:@"quizEvaluation"]) {
        APCLogDebug(@"Evaluating quiz...");
        
        self.consentRedirector.attempts++;
        
        for (NSString *question in self.resultsDictionary) {
            ORKBooleanQuestionResult *result = [self.resultsDictionary objectForKey:question];
            if (result.booleanAnswer == [NSNumber numberWithBool:1]) {
                self.correctCount++;
            }
            
            //Answer critical question 1 correctly?
            if ([result.identifier isEqualToString:@"question1"] && result.booleanAnswer == [NSNumber numberWithBool:0]){
                self.failedAttempts ++;
                self.consentRedirector.failureCount++;
                self.passedTest = NO;
                return YES;
            }
        }
        
        if (self.correctCount <2){
            self.failedAttempts ++;
            self.consentRedirector.failureCount++;
            self.passedTest = NO;
            return YES;
        }
        else
        {
            self.passedTest = YES;
            self.consentRedirector.attempts = 0;
            self.consentRedirector.failureCount = 0;
        }
        
        return YES;//always present the quiz evaluation
    }else
    return YES;
    
}

#pragma mark StepViewController delegate
-(void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction{
    
    [super stepViewController:stepViewController didFinishWithNavigationDirection:direction];
    
    if (direction == ORKStepViewControllerNavigationDirectionReverse) {
        return;
    }else if ([stepViewController.result.identifier isEqualToString:@"reviewStep"]) {
                
        //we're done - tell the parent's task delegate about the consent document
        //Collect the signature result from the step
        for (ORKStepResult *result in stepViewController.result.results) {
            if ([result isKindOfClass:[ORKConsentSignatureResult class]]) {
                self.signatureResult = (ORKConsentSignatureResult*)result;
            }
        }
        
        //return control of the task delegate to core
        self.delegate = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kReturnControlOfTaskDelegate object:nil];

        [self.delegate taskViewController: self
                      didFinishWithReason: ORKTaskViewControllerFinishReasonCompleted
                                    error: nil];

        [(APCEligibleViewController*)self.delegate startSignUp];
    }
}

#pragma mark StepViewController delegate

- (void)stepViewControllerResultDidChange:(ORKStepViewController *)stepViewController{
    
    if ([stepViewController isKindOfClass:[APHQuizStepViewController class]]) {
        APHQuizStepViewController *quizStep = (APHQuizStepViewController *)stepViewController;
        ORKQuestionResult *result = quizStep.questionResult;
        if (result) {
            [self.resultsDictionary setObject:result forKey:result.identifier];
        }
    }
    
  
}

-(void)stepViewControllerWillAppear:(ORKStepViewController *)viewController{
    if ([viewController isKindOfClass:[ORKStepViewController class]]) {
        viewController.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Consent", nil);
    }
    
    if ([viewController isKindOfClass:[APHQuizStepViewController class]]) {
        viewController.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Quiz", nil);
    }
    
    if ([viewController isKindOfClass:[APHQuizEvaluationViewController class]]) {
        viewController.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Quiz Evaluation", nil);
    }
    
}

@end
