// 
//  APHAsthmaBadgesObject.m 
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
 
#import "APHAsthmaBadgesObject.h"
#import "APHConstants.h"
@import APCAppCore;

static const int maximumWorkDays = 5;
static const int daysToSearchForCompletedWeeklySurvey = 21;

@interface APHAsthmaBadgesObject ()

@property (nonatomic, strong) NSArray * dailyScheduledTasks;
@property (nonatomic, strong) NSArray * weeklyScheduledTasks;
@property (nonatomic, strong) NSArray * completedDailyScheduledTasks;
@property (nonatomic, strong) NSArray * completedWeeklyScheduledTasks;

@end


@implementation APHAsthmaBadgesObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self calculateCompletionValue];
        [self calculateWorkAttendanceValue];
        [self calculateAsthmaFreeDaysValue];
        [self calculateUndisturbedNightsValue];
        
        [self calculateAsthmaFullyControlledValue];
    }
    return self;
}


#pragma mark - Data Providers

- (NSArray *)dailyScheduledTasks
{
    if (!_dailyScheduledTasks) {
        APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startOn" ascending:YES];
        NSFetchRequest *request = [APCScheduledTask request];
        [request setShouldRefreshRefetchedObjects:YES];
        NSDate *startDate = [NSDate startOfDay:[[NSDate date] dateByAddingDays:-4]];
        NSDate *endDate = [NSDate tomorrowAtMidnight];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startOn >= %@) AND (startOn <= %@) AND generatedSchedule.scheduleString like %@", startDate, endDate, @"0 5 * * *"];
        request.predicate = predicate;
        request.sortDescriptors = @[sortDescriptor];
        
        NSError *error = nil;
        _dailyScheduledTasks = [appDelegate.dataSubstrate.mainContext executeFetchRequest:request error:&error];
        APCLogError2(error);
    }
    
    return _dailyScheduledTasks;
}

- (NSArray *)completedDailyScheduledTasks
{
    if (!_completedDailyScheduledTasks) {
        _completedDailyScheduledTasks = [self.dailyScheduledTasks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"completed == %@", @(YES)]];
    }
    return _completedDailyScheduledTasks;
}

-(NSArray *)completedDailyPromptScheduledTasks{
    
    return [self.completedDailyScheduledTasks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"task.taskID == %@", kDailySurveyTaskID]];
    
}

-(NSArray *)weeklyScheduledTasks{
    
    if (!_weeklyScheduledTasks) {
        APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startOn" ascending:YES];
        NSFetchRequest *request = [APCScheduledTask request];
        [request setShouldRefreshRefetchedObjects:YES];
        NSDate *startDate = [NSDate startOfDay:[[NSDate date] dateByAddingDays:-daysToSearchForCompletedWeeklySurvey]];
        NSDate *endDate = [NSDate tomorrowAtMidnight];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startOn >= %@) AND (startOn <= %@) AND task.taskID == %@", startDate, endDate, kWeeklySurveyTaskID];
        
        request.predicate = predicate;
        request.sortDescriptors = @[sortDescriptor];
        
        NSError *error = nil;
        _weeklyScheduledTasks = [appDelegate.dataSubstrate.mainContext executeFetchRequest:request error:&error];
        APCLogError2(error);
    }
    
    return _weeklyScheduledTasks;
}

- (NSArray *)completedWeeklyScheduledTasks
{
    
    if (!_completedWeeklyScheduledTasks) {
        _completedWeeklyScheduledTasks = [self.weeklyScheduledTasks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"completed == %@", @(YES)]];
    }
    return _completedWeeklyScheduledTasks;
    
}

- (void) calculateCompletionValue
{
    
    APCActivitiesDateState *dateState = [[APCActivitiesDateState alloc]init];
    NSUInteger totalActivities = 0;
    NSUInteger completedActivities = 0;
    NSDictionary *dailySurveyState;
    NSDictionary *weeklySurveyState;
    NSDictionary *states;
    
    //get states for the dates we're interested in -4 and today
    NSDate *dateToQuery = [[NSDate new]dateByAddingDays:-4];
    while ([dateToQuery compare:[NSDate new]] == NSOrderedAscending || [dateToQuery compare:[NSDate new]] == NSOrderedSame) {
        states = [dateState activitiesStateForDate:dateToQuery];
        dailySurveyState = [states objectForKey:kDailySurveyTaskID];
        weeklySurveyState = [states objectForKey:kWeeklySurveyTaskID];
        
        //iterate over times in state
        for (NSDate *time in dailySurveyState) {
            if ([[dailySurveyState objectForKey:time] isEqualToNumber:@(YES)]) {
                completedActivities ++;
            }
            totalActivities++;
        }
        
        for (NSDate *time in weeklySurveyState) {
            if ([[weeklySurveyState objectForKey:time] isEqualToNumber:@(YES)]) {
                completedActivities ++;
            }
            totalActivities++;
        }
        
        dateToQuery = [dateToQuery dateByAddingDays:1];
    }
    
    if (totalActivities == 0) {
        _completionValue = 0;
    }else{
        _completionValue = (double)completedActivities/(double)totalActivities;
    }
}

#pragma mark Row Value Calculations
- (void) calculateWorkAttendanceValue
{
    _workAttendanceValue = -1;
    if (self.completedWeeklyScheduledTasks.count > 0) {
        APCScheduledTask *completedWeeklyTask = self.completedWeeklyScheduledTasks.lastObject;
        
        NSString * resultSummary = completedWeeklyTask.lastResult.resultSummary;
        NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : [NSDictionary new];
        
        NSString *keyString;
        int missedDays = 0;
        for (int i = 0; i < 7; i++) {
            keyString = [kDaysMissedKey stringByAppendingFormat:@"%i", i];
            if (dictionary[keyString]) {
                missedDays++;
            }
        }
        
        if (missedDays > 5) {
            missedDays = 5;
        }
        NSNumber *inferredWorkedDays;
        if (maximumWorkDays - missedDays > 0) {
            inferredWorkedDays = [NSNumber numberWithInt:(maximumWorkDays - missedDays)];
        }else{
            inferredWorkedDays = [NSNumber numberWithInt:0];
        }
        
        _workAttendanceValue = (float)inferredWorkedDays.floatValue/(float)maximumWorkDays;
    }
}

- (void) calculateAsthmaFreeDaysValue
{
    NSArray *dailyPromptTasks = [self completedDailyPromptScheduledTasks];
    NSUInteger dailyPromptedTaskCount = dailyPromptTasks.count;
    
    if (dailyPromptedTaskCount == 0) {
        _asthmaFreeDaysValue = 0;
    }
    else
    {
        __block NSInteger freeDays = 0;
        [dailyPromptTasks enumerateObjectsUsingBlock:^(APCScheduledTask * obj, NSUInteger __unused idx, BOOL __unused *stop) {
            NSString * resultSummary = obj.lastResult.resultSummary;
            NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : nil;
            if ([dictionary[kDaytimeSickKey] isEqualToNumber:@(NO)]) {
                freeDays ++;
            }
        }];
        _asthmaFreeDaysValue = (double)freeDays/(double)dailyPromptedTaskCount;
    }
}

- (void) calculateUndisturbedNightsValue
{
    NSArray *dailyPromptTasks = [self completedDailyPromptScheduledTasks];
    NSUInteger dailyPromptedTaskCount = dailyPromptTasks.count;
    
    if (dailyPromptedTaskCount == 0) {
        _undisturbedNightsValue = 0;
    }
    else
    {
        __block NSInteger freeNights = 0;
        [dailyPromptTasks enumerateObjectsUsingBlock:^(APCScheduledTask * obj, NSUInteger __unused idx, BOOL __unused *stop) {
            NSString * resultSummary = obj.lastResult.resultSummary;
            NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : nil;
            if ([dictionary[kNighttimeSickKey] isEqualToNumber:@(NO)]) {
                freeNights ++;
            }
        }];
        _undisturbedNightsValue = (double)freeNights/(double)dailyPromptedTaskCount;
    }
}

- (void) calculateAsthmaFullyControlledValue
{
    //    < 2 days of daytime symptoms (daily survey)
    NSUInteger maxNumberOfDaytimeSymptoms = 2;
    //    Use of quick relief medicine on < 2 days and < 4 occasions/wk (daily survey)
    NSUInteger maxNumberQuickReliefUsage = 4;
    //    No nocturnal symptoms (daily survey)
    //    No exacerbations (no use of prednisone) (weekly survey, applies to BOTH prednisone questions)
    //    No emergency visits (or hospitalizations, or unscheduled MD visit for asthma)  (weekly survey)
    //    No treatment related side effects (weekly survey)
    
    NSUInteger daytimeSymptoms = 0;
    NSUInteger quickReliefUsage = 0;
    NSUInteger nocturalSymptoms = 0;
    NSUInteger excerbations = 0;
    NSUInteger emergencyVisit = 0;
    NSUInteger relatedSideEffects = 0;
    for (APCScheduledTask * dailyCompletedTask in self.completedDailyScheduledTasks) {
        NSString * resultSummary = dailyCompletedTask.lastResult.resultSummary;
        NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : nil;
        if ([dictionary[kDaytimeSickKey] boolValue]) {
            daytimeSymptoms ++;
        }
        if ([dictionary[kQuickReliefKey] integerValue]) {
            quickReliefUsage += [dictionary[kQuickReliefKey] integerValue];
        }
        if ([dictionary[kNighttimeSickKey] boolValue]) {
            nocturalSymptoms ++;
        }
    }
    
    if (self.completedWeeklyScheduledTasks.lastObject) {
        APCScheduledTask *weeklyCompletedTask = (APCScheduledTask *)self.completedWeeklyScheduledTasks.lastObject;
        NSString * resultSummary = weeklyCompletedTask.lastResult.resultSummary;
        NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : nil;
        if ([dictionary[kSteroid1Key] boolValue] || [dictionary[kSteroid2Key] boolValue]) {
            excerbations ++;
        }
        if ([dictionary[kVisit1Key] boolValue] || [dictionary[kVisit2Key] boolValue]) {
            emergencyVisit ++;
        }
        if ([dictionary[kSideEffectKey] boolValue]) {
            relatedSideEffects ++;
        }
    }
    
    NSUInteger totalScore = 0;
    NSUInteger userScore  = 0;
    NSUInteger defaultScore = 10;
    
    if (self.completedDailyScheduledTasks.count > 0 || self.completedWeeklyScheduledTasks.count > 0) {
        //    < 2 days of daytime symptoms (daily survey)
        totalScore+=defaultScore;
        userScore = (daytimeSymptoms < maxNumberOfDaytimeSymptoms) ? userScore+defaultScore : userScore;
        
        //    Use of quick relief medicine on < 2 days and < 4 occasions/wk (daily survey)
        totalScore+=defaultScore;
        userScore = (quickReliefUsage < maxNumberQuickReliefUsage) ? userScore+defaultScore : userScore;
        
        //    No nocturnal symptoms (daily survey)
        totalScore+=defaultScore;
        userScore = (nocturalSymptoms == 0) ? userScore+defaultScore : userScore;
        
        //    No exacerbations (no use of prednisone) (weekly survey, applies to BOTH prednisone questions)
        totalScore+=defaultScore;
        userScore = (excerbations == 0) ? userScore+defaultScore : userScore;
        
        //    No emergency visits (or hospitalizations, or unscheduled MD visit for asthma)  (weekly survey)
        totalScore+=defaultScore;
        userScore = (emergencyVisit == 0) ? userScore+defaultScore : userScore;
        
        //    No treatment related side effects (weekly survey)
        totalScore+=defaultScore;
        userScore = (relatedSideEffects == 0) ? userScore+defaultScore : userScore;
    }
    
    _asthmaFullyControlUserScore = userScore;
    _asthmaFullyControlTotalScore = totalScore;
    
}


@end
