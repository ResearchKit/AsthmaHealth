// 
//  APHCalendarDataModel.m 
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
 
#import "APHCalendarDataModel.h"
#import "APHConstants.h"
static float const kParticipationTrophyThreshold = 0.85;

@implementation APHCalendarDataModel

#pragma mark APHCalendarCollectionViewController delegate
-(NSDictionary *)userCompliedWithDailyScheduledTasks:(APHCalendarTaskType)task inMonth:(NSUInteger)month inYear:(NSUInteger)year{
    
    NSMutableDictionary *complianceDictionary = [[NSMutableDictionary alloc]init];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    APCDateRange *dateRange;
    
    if (task == kAPHCalendarTaskTypeParticipation) {
        
        for (int day = 1; day < 32; day++) {
            [comps setDay:day];
            [comps setMonth:month];
            [comps setYear:year];
            
            NSDate *date = [gregorian dateFromComponents:comps];
            
            if ([date earlierDate:[NSDate new]] == date) {
                
                dateRange = [[APCDateRange alloc]initWithStartDate:date durationInterval:86400];
                
                NSInteger scheduled = [APHCalendarDataModel allScheduledTasksForDateRange:dateRange completed:nil inContext:((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext].count;
                
                if (scheduled > 0) {
                    
                    NSInteger completedScheduled = [APHCalendarDataModel allScheduledTasksForDateRange:dateRange completed:[NSNumber numberWithBool:1] inContext:((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext].count;
                    
                    if ((float)completedScheduled / (float)scheduled > kParticipationTrophyThreshold){
                        [complianceDictionary setObject:@"1" forKey:[NSString stringWithFormat:@"%i", day]];
                    }else{
                        [complianceDictionary setObject:@"0" forKey:[NSString stringWithFormat:@"%i", day]];
                    }
                }
            }else{
                return complianceDictionary;
            }
        }
        
        return complianceDictionary;
    }
    
    if (task == kAPHCalendarTaskTypeAttendance) {
        //get a date range for the month using date components
        [comps setDay:1];
        [comps setMonth:month];
        [comps setYear:year];
        NSDate *startDate = [gregorian dateFromComponents:comps];
        
        //need to include 1 week of following month in retrospective
        [comps setDay:7];
        [comps setMonth:month +1];
        [comps setYear:year];
        NSDate *endDate = [gregorian dateFromComponents:comps];
        
        dateRange = [[APCDateRange alloc]initWithStartDate:startDate endDate:endDate];
        
        //get the weekly prompt tasks within the date range
        NSArray *completedScheduledTasks = [APHCalendarDataModel allScheduledWeeklyPromptTasksForDateRange:dateRange completed:@YES inContext:((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext];
        
        //iterate over the weekly prompt tasks
        for (APCScheduledTask *task in completedScheduledTasks) {
            
            //the task startDate is always a Saturday because that's the delivery date.
            //However, the results always relate to the prior week from Sun to Sat
            NSDate *startOn = task.startOn;
            
            //Sunday of prior week
            NSDate *priorSunday = [NSDate priorSundayAtMidnightFromDate:startOn];
            
            NSDate *dateToExamine = priorSunday;
            
            //get the weekday corresponding to dateToExamine
            NSDateComponents *dayComponents = [gregorian components:(NSCalendarUnitWeekday) fromDate:dateToExamine];
            NSInteger weekday = [dayComponents weekday];
            NSDateComponents *monthComponents = [gregorian components:(NSCalendarUnitMonth) fromDate:dateToExamine];
            
            while (weekday < 8) {
                //get the day of month for startOn
                NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitDay) fromDate:dateToExamine];
                int day = (int)[weekdayComponents day];
                
                //get the result summary for this weekly prompt task
                NSString * resultSummary = task.lastResult.resultSummary;
                NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : nil;
                
                //check we're still in the current month
                if ((int)monthComponents.month == (int)month) {
                    NSString *keyString = [kDaysMissedKey stringByAppendingFormat:@"%i", (int)weekday];
                    if (dictionary[keyString]) {//missed work, red == 0
                        [complianceDictionary setObject:@"0" forKey:[NSString stringWithFormat:@"%i", day]];
                    }else{
                        [complianceDictionary setObject:@"1" forKey:[NSString stringWithFormat:@"%i", day]];
                    }
                }
                
                weekday++;
                dateToExamine = [dateToExamine dateByAddingDays:1];
                monthComponents = [gregorian components:(NSCalendarUnitMonth) fromDate:dateToExamine];
            }
            
        }
        
        return complianceDictionary;
        
    }
    
    if (task == kAPHCalendarTaskTypeFreeNights) {
        
        //get a date range for the month using date components
        [comps setDay:1];
        [comps setMonth:month];
        [comps setYear:year];
        NSDate *startDate = [gregorian dateFromComponents:comps];
        
        [comps setDay:31];
        [comps setMonth:month];
        [comps setYear:year];
        NSDate *endDate = [gregorian dateFromComponents:comps];
        
        dateRange = [[APCDateRange alloc]initWithStartDate:startDate endDate:endDate];
        
        //get array of completed scheduled tasks
        NSArray *completedScheduledTasks = [APHCalendarDataModel allScheduledDailyPromptTasksForDateRange:dateRange completed:@YES inContext:((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext];
        
        for (APCScheduledTask *task in completedScheduledTasks) {
            NSDate *startOn = task.startOn;
            
            if ([startOn earlierDate:[NSDate new]] == startOn) {//no need to parse scheduled tasks after today
                NSString * resultSummary = task.lastResult.resultSummary;
                NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : nil;
                NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitDay) fromDate:startOn];
                int day = (int)[weekdayComponents day];
                if (dictionary[kNighttimeSickKey]) {//had symptoms, red == 0
                    [complianceDictionary setObject:@"0" forKey:[NSString stringWithFormat:@"%i", day]];
                }else{
                    [complianceDictionary setObject:@"1" forKey:[NSString stringWithFormat:@"%i", day]];
                }
            }
        }
        return complianceDictionary;
    }
    
    if (task == kAPHCalendarTaskTypeFreeDays) {
        //get a date range for the month using date components
        [comps setDay:1];
        [comps setMonth:month];
        [comps setYear:year];
        NSDate *startDate = [gregorian dateFromComponents:comps];
        
        [comps setDay:31];
        [comps setMonth:month];
        [comps setYear:year];
        NSDate *endDate = [gregorian dateFromComponents:comps];
        
        dateRange = [[APCDateRange alloc]initWithStartDate:startDate endDate:endDate];
        
        //get array of completed scheduled tasks
        NSArray *completedScheduledTasks = [APHCalendarDataModel allScheduledDailyPromptTasksForDateRange:dateRange completed:@YES inContext:((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext];
        
        for (APCScheduledTask *task in completedScheduledTasks) {
            NSDate *startOn = task.startOn;
            
            if ([startOn earlierDate:[NSDate new]] == startOn) {//no need to parse scheduled tasks after today
                NSString * resultSummary = task.lastResult.resultSummary;
                NSDictionary * dictionary = resultSummary ? [NSDictionary dictionaryWithJSONString:resultSummary] : nil;
                NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitDay) fromDate:startOn];
                int day = (int)[weekdayComponents day];
                if (dictionary[kDaytimeSickKey]) {//had symptoms, red == 0
                    [complianceDictionary setObject:@"0" forKey:[NSString stringWithFormat:@"%i", day]];
                }else{
                    [complianceDictionary setObject:@"1" forKey:[NSString stringWithFormat:@"%i", day]];
                }
            }
        }
    }
    return complianceDictionary;
}

+ (NSArray *)allScheduledTasksForDateRange: (APCDateRange*) dateRange completed: (NSNumber*) completed inContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    request.shouldRefreshRefetchedObjects = YES;
    NSPredicate * datePredicate = [NSPredicate predicateWithFormat:@"(startOn >= %@) AND (endOn <= %@)", dateRange.startDate, dateRange.endDate];
    
    NSPredicate * completionPredicate = nil;
    if (completed != nil) {
        completionPredicate = [completed isEqualToNumber:@YES] ? [NSPredicate predicateWithFormat:@"completed == %@", completed] :[NSPredicate predicateWithFormat:@"completed == nil ||  completed == %@", completed] ;
    }
    
    NSPredicate * finalPredicate = completionPredicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate, completionPredicate]] : datePredicate;
    request.predicate = finalPredicate;
    
    NSSortDescriptor *titleSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"task.taskTitle" ascending:YES];
    NSSortDescriptor * completedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES];
    request.sortDescriptors = @[completedSortDescriptor, titleSortDescriptor];
    
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    if (array == nil) {
        APCLogError2 (error);
    }
    
    NSMutableArray * filteredArray = [NSMutableArray array];
    
    for (APCScheduledTask * scheduledTask in array) {
        if ([scheduledTask.dateRange compare:dateRange] != kAPCDateRangeComparisonOutOfRange) {
            [filteredArray addObject:scheduledTask];
        }
    }
    return filteredArray.count ? filteredArray : nil;
}

+ (NSArray *)allScheduledDailyPromptTasksForDateRange: (APCDateRange*) dateRange completed: (NSNumber*) completed inContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    request.shouldRefreshRefetchedObjects = YES;
    NSPredicate * datePredicate = [NSPredicate predicateWithFormat:@"(startOn >= %@) AND (endOn <= %@) AND task.taskID == %@", dateRange.startDate, dateRange.endDate, kDailySurveyTaskID];
    
    NSPredicate * completionPredicate = nil;
    if (completed != nil) {
        completionPredicate = [completed isEqualToNumber:@YES] ? [NSPredicate predicateWithFormat:@"completed == %@", completed] :[NSPredicate predicateWithFormat:@"completed == nil ||  completed == %@", completed] ;
    }
    
    NSPredicate * finalPredicate = completionPredicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate, completionPredicate]] : datePredicate;
    request.predicate = finalPredicate;
    
    NSSortDescriptor *titleSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"task.taskTitle" ascending:YES];
    NSSortDescriptor * completedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES];
    request.sortDescriptors = @[completedSortDescriptor, titleSortDescriptor];
    
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    if (array == nil) {
        APCLogError2 (error);
    }
    
    NSMutableArray * filteredArray = [NSMutableArray array];
    
    for (APCScheduledTask * scheduledTask in array) {
        if ([scheduledTask.dateRange compare:dateRange] != kAPCDateRangeComparisonOutOfRange) {
            [filteredArray addObject:scheduledTask];
        }
    }
    return filteredArray.count ? filteredArray : nil;
}

+ (NSArray *)allScheduledWeeklyPromptTasksForDateRange: (APCDateRange*) dateRange completed: (NSNumber*) completed inContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * request = [APCScheduledTask request];
    request.shouldRefreshRefetchedObjects = YES;
    NSPredicate * datePredicate = [NSPredicate predicateWithFormat:@"(startOn >= %@) AND (endOn <= %@) AND task.taskID == %@", dateRange.startDate, dateRange.endDate, kWeeklySurveyTaskID];
    
    NSPredicate * completionPredicate = nil;
    if (completed != nil) {
        completionPredicate = [completed isEqualToNumber:@YES] ? [NSPredicate predicateWithFormat:@"completed == %@", completed] :[NSPredicate predicateWithFormat:@"completed == nil ||  completed == %@", completed] ;
    }
    
    NSPredicate * finalPredicate = completionPredicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate, completionPredicate]] : datePredicate;
    request.predicate = finalPredicate;
    
    NSSortDescriptor *titleSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"task.taskTitle" ascending:YES];
    NSSortDescriptor * completedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES];
    request.sortDescriptors = @[completedSortDescriptor, titleSortDescriptor];
    
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    if (array == nil) {
        APCLogError2 (error);
    }
    
    NSMutableArray * filteredArray = [NSMutableArray array];
    
    for (APCScheduledTask * scheduledTask in array) {
        if ([scheduledTask.dateRange compare:dateRange] != kAPCDateRangeComparisonOutOfRange) {
            [filteredArray addObject:scheduledTask];
        }
    }
    return filteredArray.count ? filteredArray : nil;
}

@end
