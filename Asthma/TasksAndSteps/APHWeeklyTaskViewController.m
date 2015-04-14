// 
//  APHWeeklyTaskViewController.m 
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
 
#import "APHWeeklyTaskViewController.h"
#import "APHConstants.h"

@implementation APHWeeklyTaskViewController

- (NSString*) createResultSummary
{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    
    {//Steroid 1 Step
        ORKBooleanQuestionResult *result = (ORKBooleanQuestionResult *)[self answerForSurveyStepIdentifier:kSteroid1StepIdentifier];
        if ([result booleanAnswer]) {
            dictionary[kSteroid1Key] = [result booleanAnswer];
        }

    }
    {//Steroid 2 Step
        ORKBooleanQuestionResult *result = (ORKBooleanQuestionResult *)[self answerForSurveyStepIdentifier:kSteroid2StepIdentifier];
        if ([result booleanAnswer]) {
            dictionary[kSteroid2Key] = [result booleanAnswer];
        }
    }
    {//Visit 1 Step
        ORKBooleanQuestionResult *result = (ORKBooleanQuestionResult *)[self answerForSurveyStepIdentifier:kVisit1StepIdentifier];
        if ([result booleanAnswer]) {
            dictionary[kVisit1Key] = [result booleanAnswer];
        }
    }
    
    {//Visit 2 Step
        ORKBooleanQuestionResult *result = (ORKBooleanQuestionResult *) [self answerForSurveyStepIdentifier:kVisit2StepIdentifier];
        if ([result booleanAnswer]) {
            dictionary[kVisit2Key] = [result booleanAnswer];
        }
    }
    
    {//Side Effect Step
        ORKChoiceQuestionResult *result = (ORKChoiceQuestionResult *)[self answerForSurveyStepIdentifier:kSideEffectStepIdentifier];
        
        if ([[result choiceAnswers]firstObject]) {
            dictionary[kSideEffectKey] = [[result choiceAnswers]firstObject];
        }
    }
    
    {//Miss Work Step
        ORKBooleanQuestionResult *result = (ORKBooleanQuestionResult *) [self answerForSurveyStepIdentifier:kMissWorkStepIdentifier];
        if ([result booleanAnswer]) {
            dictionary[kMissWorkKey] = [result booleanAnswer];
        }
    }
    {//Days Missed Step
        ORKChoiceQuestionResult *result = (ORKChoiceQuestionResult *) [self answerForSurveyStepIdentifier:kDaysMissedStepIdentifier];
        if ([result choiceAnswers]) {
            NSArray *choiceAnswers = result.choiceAnswers ? result.choiceAnswers : [NSArray new];
            
            if (choiceAnswers.count >0) {
                for (NSString *day in choiceAnswers) {
                    NSString *keyString = [kDaysMissedKey stringByAppendingFormat:@"%@",day];
                    dictionary[keyString] = @"1";
                }
            }
        }
    }
    
    return [dictionary JSONString];
}

- (ORKResult *) answerForSurveyStepIdentifier: (NSString*) identifier
{
    NSArray * stepResults = [(ORKStepResult*)[self.result resultForIdentifier:identifier] results];
    ORKStepResult *answer = (ORKStepResult *)[stepResults firstObject];
    return answer;
}

@end
