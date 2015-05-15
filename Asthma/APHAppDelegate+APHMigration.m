// 
//  APHAppDelegate+APHMigration.m 
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
 
#import "APHAppDelegate+APHMigration.h"

@implementation APHAppDelegate (APHMigration)

- (BOOL) performMigrationFromOneToTwoWithError:(NSError *__autoreleasing *)error{
    
    BOOL success = [self addEuroQoLSurvey] && [self updateAllSurveysWithError:error];
    
    return success;
}
    
- (BOOL) performMigrationFromTwoToThreeWithError:(NSError * __autoreleasing *)error
{
    BOOL    success = [self addRecontactSurvey] && [self updateAllSurveysWithError:error];
    
    return success;
}

-(BOOL) performMigrationFromThreeToFourWithError:(NSError * __autoreleasing *)__unused error
{
    return [self turnOnAllTaskReminders];
}

- (BOOL)updateAllSurveysWithError:(NSError *__autoreleasing *)error {
    
    BOOL success = NO;
    
    NSError*        jsonError;
    NSString*       resource    = [[NSBundle mainBundle] pathForResource:@"APHTasksAndSchedules" ofType:@"json"];
    NSData*         jsonData    = [NSData dataWithContentsOfFile:resource];
    NSDictionary*   dictionary  = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
    
    if (!jsonError)
    {
        [APCTask updateTasksFromJSON:dictionary[@"tasks"]
                           inContext:self.dataSubstrate.persistentContext];
        
        success = YES;
        
    } else {
        
        APCLogError2(jsonError);
        *error =  jsonError;
    }
    
    return success;
}


- (BOOL)addEuroQoLSurvey {    
    
    NSDictionary * staticScheduleAndTask = @{ @"tasks":
                                                  @[
                                                      @{
                                                          @"taskTitle"                : @"EuroQoL Quality of Life Survey",
                                                          @"taskID"                   : @"EQ5D-00d025a0-c12b-11e4-8dfc-aa07a5b093db",
                                                          @"taskFileName"             : @"EQ_5D",
                                                          @"taskClassName"            : @"APHEQ5TaskViewController",
                                                          @"taskCompletionTimeString" : @"9 Questions"
                                                          }
                                                      ],
                                              
                                              @"schedules":
                                                  @[
                                                      
                                                      @{
                                                          @"expires"     : @"P89D",
                                                          @"scheduleType"     : @"once",
                                                          @"taskID"           : @"EQ5D-00d025a0-c12b-11e4-8dfc-aa07a5b093db"
                                                          }
                                                      ]
                                              };
    
    [APCTask updateTasksFromJSON:staticScheduleAndTask[@"tasks"]
                       inContext:self.dataSubstrate.persistentContext];
    
    [APCSchedule createSchedulesFromJSON:staticScheduleAndTask[@"schedules"]
                               inContext:self.dataSubstrate.persistentContext];
    
    APCScheduler *scheduler = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate];
    [scheduler updateScheduledTasksIfNotUpdating:YES];
     
    return YES;
}

- (BOOL)addRecontactSurvey
{
    NSDictionary * staticScheduleAndTask = @{ @"tasks":
                                                  @[
                                                      @{
                                                          @"taskTitle" : @"Enrollment for Recontact",
                                                          @"taskID": @"APHEnrollmentForRecontactTaskViewController-1E174065-5B02-11E4-8ED6-0800200C9A66",
                                                          @"taskClassName" : @"APHEnrollmentForRecontactTaskViewController",
                                                          @"taskCompletionTimeString" : @"1 Question"
                                                          }
                                                      ],
                                              
                                              @"schedules":
                                                  @[
                                                      
                                                      @{
                                                          @"scheduleType": @"once",
                                                          @"taskID": @"APHEnrollmentForRecontactTaskViewController-1E174065-5B02-11E4-8ED6-0800200C9A66"
}
                                                      ]
                                              };
    
    [APCTask updateTasksFromJSON:staticScheduleAndTask[@"tasks"]
                       inContext:self.dataSubstrate.persistentContext];
    
    [APCSchedule createSchedulesFromJSON:staticScheduleAndTask[@"schedules"]
                               inContext:self.dataSubstrate.persistentContext];

    APCScheduler *scheduler = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate];
    [scheduler updateScheduledTasksIfNotUpdating:YES];

    return YES;
}

- (BOOL)turnOnAllTaskReminders
{
    //turn all task reminders on
    [self setUpTasksReminder];
    for (APCTaskReminder *reminder in self.tasksReminder.reminders) {
        if (![[NSUserDefaults standardUserDefaults]objectForKey:reminder.reminderIdentifier]) {
            [[NSUserDefaults standardUserDefaults]setObject:reminder.reminderBody forKey:reminder.reminderIdentifier];
        }
    }
    
    //Enable reminders if notifications permitted
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone){
        [self.tasksReminder setReminderOn:@YES];
    }

    [[NSUserDefaults standardUserDefaults]synchronize];
    
    return self.tasksReminder.reminders.count;
    
}

@end
