// 
//  APHAppDelegate.m 
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
 
@import APCAppCore;
#import "APHAppDelegate.h"
#import "APHConsentTaskViewController.h"
#import "APHBooleanQuestionStep.h"
#import "APHConsentTask.h"
#import "APHAppDelegate+APHMigration.h"
#import "APHConstants.h"
#import "APHAirQualityDataModel.h"

/*********************************************************************************/
#pragma mark - Initializations Options
/*********************************************************************************/
static NSString *const kStudyIdentifier                 = @"studyname";
static NSString *const kAppPrefix                       = @"studyname";
static NSString *const kVideoShownKey                   = @"VideoShown";
static NSString *const kWeeklyScheduleTaskId            = @"WeeklySurvey-b573a78-8917-4582-8f1f-0552d0bfd28a";
static NSString *const kJsonSchedulesKey                = @"schedules";
static NSString *const kJsonScheduleStringKey           = @"scheduleString";
static NSString *const kJsonScheduleTaskIDKey           = @"taskID";
static NSString *const kJsonTasksKey                    = @"tasks";
static NSString *const kConsentPropertiesFileName       = @"APHConsentSection";
static NSString *const kPreviousVersionKey              = @"previousVersion";
/*********************************************************************************/
#pragma mark - Research Kit Controls Customisation
/*********************************************************************************/

@interface APHAppDelegate ( )

@property  (nonatomic, strong)  NSArray  *rkControlCusomisations;
@property  (nonatomic, strong)  ORKConsentDocument *consentDocument;
@property  (nonatomic, strong)  HKHealthStore *healthStore;
@property  (nonatomic, assign)  NSInteger environment;
@end

@implementation APHAppDelegate


/*********************************************************************************/
#pragma mark - App Specific Code
/*********************************************************************************/

- (void)performMigrationAfterDataSubstrateFrom:(NSInteger) __unused previousVersion currentVersion:(NSInteger) __unused currentVersion
{
    NSDictionary*   infoDictionary      = [[NSBundle mainBundle] infoDictionary];
    NSString*       majorVersion        = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString*       minorVersion        = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSUserDefaults* defaults            = [NSUserDefaults standardUserDefaults];
    NSError*        migrationError      = nil;
    
    if ([self doesPersisteStoreExist] == NO)
    {
        APCLogEvent(@"This application is being launched for the first time. We know this because there is no persistent store.");
    }
    else if ( [defaults objectForKey:kPreviousVersionKey] == nil)
    {
        APCLogEvent(@"The entire data model version %d", kTheEntireDataModelOfTheApp);
        if (![self performMigrationFromOneToTwoWithError:&migrationError])
        {
            APCLogEvent(@"Migration from version 1 to 2 has failed.");
        }

        if (![self performMigrationFromTwoToThreeWithError:&migrationError])
        {
            APCLogEvent(@"Migration from version %@ to %@ has failed.", [defaults objectForKey:kPreviousVersionKey], @(kTheEntireDataModelOfTheApp));
        }
    }
    else if ([[defaults objectForKey:kPreviousVersionKey] isEqual: @2])
    {
        APCLogEvent(@"The entire data model version %d", kTheEntireDataModelOfTheApp);
        if (![self performMigrationFromTwoToThreeWithError:&migrationError])
        {
            APCLogEvent(@"Migration from version %@ to %@ has failed.", [defaults objectForKey:kPreviousVersionKey], @(kTheEntireDataModelOfTheApp));
        }
    }
    else if ([[defaults objectForKey:kPreviousVersionKey] isEqual: @3])
    {
        APCLogEvent(@"The entire data model version %d", kTheEntireDataModelOfTheApp);
        if (![self performMigrationFromThreeToFourWithError:&migrationError])
        {
            APCLogEvent(@"Migration from version %@ to %@ has failed.", [defaults objectForKey:kPreviousVersionKey], @(kTheEntireDataModelOfTheApp));
        }
    }
    
    [defaults setObject:majorVersion
                 forKey:@"shortVersionString"];
    
    [defaults setObject:minorVersion
                 forKey:@"version"];
    

    if (!migrationError)
    {
        [defaults setObject:@(currentVersion) forKey:kPreviousVersionKey];
    }

}

- (BOOL)application:(UIApplication*) __unused application willFinishLaunchingWithOptions:(NSDictionary*) __unused launchOptions
{
    [super application:application willFinishLaunchingWithOptions:launchOptions];
    
    NSArray* dataTypesWithReadPermission = self.initializationOptions[kHKReadPermissionsKey];
    
    if (dataTypesWithReadPermission)
    {
        for (id dataType in dataTypesWithReadPermission)
        {
            HKObjectType*   sampleType  = nil;
            
            if ([dataType isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* categoryType = (NSDictionary*) dataType;
                
                //Distinguish
                if (categoryType[kHKWorkoutTypeKey])
                {
                    sampleType = [HKObjectType workoutType];
                }
                else if (categoryType[kHKCategoryTypeKey])
                {
                    sampleType = [HKObjectType categoryTypeForIdentifier:categoryType[kHKCategoryTypeKey]];
                }
            }
            else
            {
                sampleType = [HKObjectType quantityTypeForIdentifier:dataType];
            }
            
            if (sampleType)
            {
                [self.dataSubstrate.healthStore enableBackgroundDeliveryForType:sampleType
                                                                      frequency:HKUpdateFrequencyHourly
                                                                 withCompletion:^(BOOL success, NSError *error)
    {
                     if (!success)
                     {
                         if (error)
                         {
                             APCLogError2(error);
                         }
                     }
                     else
                     {
                         APCLogDebug(@"Enabling background delivery for healthkit");
                     }
                 }];
            }
        }
    }

    return YES;
}

- (void) setUpInitializationOptions
{
    
    [APCUtilities setRealApplicationName:@"Asthma Health"];
    
    NSDictionary *permissionsDescriptions = @{
                                              @(kSignUpPermissionsTypeLocation) : NSLocalizedString(@"Using your GPS will allow the app to advise you of air quality in your area. Your actual location will never be shared.", @""),
                                              @(kSignUpPermissionsTypeCoremotion) : NSLocalizedString(@"Using the motion co-processor allows the app to determine your activity, helping the study better understand how activity level may influence disease.", @""),
                                              @(kSignUpPermissionsTypeMicrophone) : NSLocalizedString(@"Access to microphone is required for your Voice Recording Activity.", @""),
                                              @(kSignUpPermissionsTypeLocalNotifications) : NSLocalizedString(@"Allowing notifications enables the app to show you reminders.", @""),
                                              @(kSignUpPermissionsTypeHealthKit) : NSLocalizedString(@"On the next screen, you will be prompted to grant Asthma access to read and write some of your general and health information, such as height, weight and steps taken so you don't have to enter it again.", @""),
                                              };
    
    NSMutableDictionary * dictionary = [super defaultInitializationOptions];
    
#ifdef DEBUG
    self.environment = SBBEnvironmentStaging;
#else
    self.environment = SBBEnvironmentProd;
#endif

    //If the HK permissions keys are updated, the HK Permissions View Controller will be shown on launch.
    [dictionary addEntriesFromDictionary:@{
                                           kStudyIdentifierKey                  : kStudyIdentifier,
                                           kAppPrefixKey                        : kAppPrefix,
                                           kBridgeEnvironmentKey                : @(self.environment),
                                           kHKReadPermissionsKey                : @[
                                                   HKQuantityTypeIdentifierBodyMass,
                                                   HKQuantityTypeIdentifierHeight,
                                                   HKQuantityTypeIdentifierStepCount,
                                                   HKQuantityTypeIdentifierPeakExpiratoryFlowRate,
                                                   HKQuantityTypeIdentifierInhalerUsage,
                                                   @{kHKCategoryTypeKey : HKCategoryTypeIdentifierSleepAnalysis}
                                                   ],
                                           kHKWritePermissionsKey                : @[
                                                   HKQuantityTypeIdentifierBodyMass,
                                                   HKQuantityTypeIdentifierHeight,
                                                   HKQuantityTypeIdentifierPeakExpiratoryFlowRate
                                                   ],
                                           kAppServicesListRequiredKey           : @[
                                                   @(kSignUpPermissionsTypeLocation),
                                                   @(kSignUpPermissionsTypeLocalNotifications)
                                                   ],
                                           kAppServicesDescriptionsKey : permissionsDescriptions,
                                           kAppProfileElementsListKey            : @[
                                                   @(kAPCUserInfoItemTypeEmail),
                                                   @(kAPCUserInfoItemTypeDateOfBirth),
                                                   @(kAPCUserInfoItemTypeBiologicalSex),
                                                   @(kAPCUserInfoItemTypeHeight),
                                                   @(kAPCUserInfoItemTypeWeight)
                                                   ]
                                           }];
    self.initializationOptions = dictionary;
}

-(void)setUpTasksReminder{
    //Reminders
    APCTaskReminder *dailySurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kDailySurveyTaskID reminderBody:NSLocalizedString(@"Daily Survey", nil)];
    APCTaskReminder *weeklySurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kWeeklyScheduleTaskId reminderBody:NSLocalizedString(@"Weekly Survey", nil)];
    
    //define completion as defined in resultsSummary
    NSPredicate *medicationPredicate = [NSPredicate predicateWithFormat:@"SELF.integerValue == 1"];
    APCTaskReminder *medicationReminder = [[APCTaskReminder alloc]initWithTaskID:kDailySurveyTaskID resultsSummaryKey:kTookMedicineKey completedTaskPredicate:medicationPredicate reminderBody:NSLocalizedString(@"Take Medication", nil)];
    
    [self.tasksReminder.reminders removeAllObjects];
    [self.tasksReminder manageTaskReminder:dailySurveyReminder];
    [self.tasksReminder manageTaskReminder:weeklySurveyReminder];
    [self.tasksReminder manageTaskReminder:medicationReminder];
    
    if ([self doesPersisteStoreExist] == NO)
    {
        APCLogEvent(@"This app is being launched for the first time. Turn all reminders on");
        for (APCTaskReminder *reminder in self.tasksReminder.reminders) {
            [[NSUserDefaults standardUserDefaults]setObject:reminder.reminderBody forKey:reminder.reminderIdentifier];
}

        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone){
            [self.tasksReminder setReminderOn:@YES];
        }
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
}

- (void) setUpAppAppearance
{
    [APCAppearanceInfo setAppearanceDictionary:@{
                                                 kPrimaryAppColorKey : [UIColor colorWithRed:0.133 green:0.122 blue:0.447 alpha:1.000],
                                                 @"DailyPrompt-27829fa5-d731-4372-ba30-a5859f655297" : [UIColor appTertiaryGreenColor],
                                                 @"WeeklySurvey-b573a78-8917-4582-8f1f-0552d0bfd28a" : [UIColor appTertiaryGreenColor],
                                                 @"MedicalHistory-b3cd0d66-b943-11e4-a71e-12e3f512a338" : [UIColor appTertiaryPurpleColor],
                                                 @"AsthmaMedication-c2379e84-b943-11e4-a71e-12e3f512a338" : [UIColor appTertiaryPurpleColor],
                                                 @"YourAsthma-cc06cd68-b943-11e4-a71e-12e3f512a338" : [UIColor appTertiaryPurpleColor],
                                                 @"AsthmaHistory-d6d07ba4-b943-11e4-a71e-12e3f512a338" : [UIColor appTertiaryPurpleColor],
                                                 @"APHEnrollmentForRecontactTaskViewController-1E174065-5B02-11E4-8ED6-0800200C9A66" : [UIColor appTertiaryPurpleColor],
                                                 @"AboutYou-27829fa5-d731-4372-ba30-a5859f688297" : [UIColor appTertiaryPurpleColor],
                                                 }];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName : [UIColor appSecondaryColor1],
                                                            NSFontAttributeName : [UIFont appNavBarTitleFont]
                                                            }];
    
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    self.dataSubstrate.parameters.hideExampleConsent = NO;
}

- (void) showOnBoarding
{
    APCStudyOverviewViewController *studyController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"StudyOverviewVC"];
    [self setUpRootViewController:studyController];
}

- (BOOL) isVideoShown
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoShownKey];
}

- (void)instantiateOnboardingForType:(APCOnboardingTaskType)type
{
    [super instantiateOnboardingForType:type];
    
    {
        //Custom Ineligible Screen
        APCScene *scene = [APCScene new];
        scene.name = @"APHInEligibleViewController";
        scene.storyboardName = @"APHOnboarding";
        scene.bundle = [NSBundle mainBundle];
        
        [self.onboarding setScene:scene forIdentifier:kAPCSignUpIneligibleStepIdentifier];
    }
}

- (NSArray *)offsetForTaskSchedules
{
    return @[
             @{
                 kScheduleOffsetTaskIdKey: @"YourAsthma-cc06cd68-b943-11e4-a71e-12e3f512a338",
                 kScheduleOffsetOffsetKey: @(1)
                 },
             @{
                 kScheduleOffsetTaskIdKey: @"AboutYou-27829fa5-d731-4372-ba30-a5859f688297",
                 kScheduleOffsetOffsetKey: @(2)
                 },
             @{
                 kScheduleOffsetTaskIdKey: @"MedicalHistory-b3cd0d66-b943-11e4-a71e-12e3f512a338",
                 kScheduleOffsetOffsetKey: @(3)
                 }
             ];
}

/*********************************************************************************/
#pragma mark - Background Notification of Health Kit Updates
/*********************************************************************************/
/*********************************************************************************/
#pragma mark - Datasubstrate Delegate Methods
/*********************************************************************************/
- (void) setUpCollectors
{
    if (self.dataSubstrate.currentUser.userConsented)
    {
        if (!self.passiveDataCollector)
        {
            self.passiveDataCollector = [[APCPassiveDataCollector alloc] init];
        }
        
        self.airQualityDataModel = [[APHAirQualityDataModel alloc]init];
        [self configureObserverQueries];
    }
}

- (void)configureObserverQueries
{
    NSDate* (^LaunchDate)() = ^
    {
        APCUser*    user        = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
        NSDate*     consentDate = nil;
        
        if (user.consentSignatureDate)
        {
            consentDate = user.consentSignatureDate;
        }
        else
        {
            NSFileManager*  fileManager = [NSFileManager defaultManager];
            NSString*       filePath    = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"db.sqlite"];
            
            if ([fileManager fileExistsAtPath:filePath])
            {
                NSError*        error       = nil;
                NSDictionary*   attributes  = [fileManager attributesOfItemAtPath:filePath error:&error];
                
                if (error)
                {
                    APCLogError2(error);
                    
                    consentDate = [[NSDate date] startOfDay];
                }
                else
                {
                    consentDate = [attributes fileCreationDate];
                }
            }
        }
        
        return consentDate;
    };
    
    NSString*(^QuantityDataSerializer)(id) = ^NSString*(id dataSample)
    {
        HKQuantitySample*   qtySample           = (HKQuantitySample *)dataSample;
        NSString*           startDateTimeStamp  = [qtySample.startDate toStringInISO8601Format];
        NSString*           endDateTimeStamp    = [qtySample.endDate toStringInISO8601Format];
        NSString*           healthKitType       = qtySample.quantityType.identifier;
        NSString*           quantityValueRep    = [NSString stringWithFormat:@"%@", qtySample.quantity];
        NSArray*            valueSplit          = [quantityValueRep componentsSeparatedByString:@" "];
        NSString*           quantityValue       = [valueSplit objectAtIndex:0];
        NSString*           quantityUnit        = @"";
        
        for (int i = 1; i < (int)[valueSplit count]; i++)
        {
            quantityUnit = [quantityUnit stringByAppendingString:valueSplit[i]];
        }
        
        NSString*           sourceIdentifier    = qtySample.source.bundleIdentifier;
        NSString*           quantitySource      = qtySample.source.name;
        
        if (quantitySource == nil)
        {
            quantitySource = @"not available";
        }
        else if ([[[UIDevice currentDevice] name] isEqualToString:quantitySource])
        {
            if ([APCDeviceHardware platformString])
            {
                quantitySource = [APCDeviceHardware platformString];
            }
            else
            {
                //  This shouldn't get called.
                quantitySource = @"iPhone";
            }
        }
        
        NSString *stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@\n",
                                   startDateTimeStamp,
                                   endDateTimeStamp,
                                   healthKitType,
                                   quantityValue,
                                   quantityUnit,
                                   quantitySource,
                                   sourceIdentifier];
        
        return stringToWrite;
    };
    
    NSString*(^WorkoutDataSerializer)(id) = ^(id dataSample)
    {
        HKWorkout*  sample                      = (HKWorkout*)dataSample;
        NSString*   startDateTimeStamp          = [sample.startDate toStringInISO8601Format];
        NSString*   endDateTimeStamp            = [sample.endDate toStringInISO8601Format];
        NSString*   healthKitType               = sample.sampleType.identifier;
        NSString*   activityType                = [HKWorkout workoutActivityTypeStringRepresentation:(int)sample.workoutActivityType];
        double      energyConsumedValue         = [sample.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
        NSString*   energyConsumed              = [NSString stringWithFormat:@"%f", energyConsumedValue];
        NSString*   energyUnit                  = [HKUnit kilocalorieUnit].description;
        double      totalDistanceConsumedValue  = [sample.totalDistance doubleValueForUnit:[HKUnit meterUnit]];
        NSString*   totalDistance               = [NSString stringWithFormat:@"%f", totalDistanceConsumedValue];
        NSString*   distanceUnit                = [HKUnit meterUnit].description;
        NSString*   sourceIdentifier            = sample.source.bundleIdentifier;
        NSString*   quantitySource              = sample.source.name;
        
        if (quantitySource == nil)
        {
            quantitySource = @"not available";
        }
        else if ([[[UIDevice currentDevice] name] isEqualToString:quantitySource])
        {
            if ([APCDeviceHardware platformString])
            {
                quantitySource = [APCDeviceHardware platformString];
            }
            else
            {
                //  This shouldn't get called.
                quantitySource = @"iPhone";
            }
        }
        
        NSError*    error                       = nil;
        NSString*   metaData                    = [NSDictionary convertDictionary:sample.metadata ToStringWithReturningError:&error];
        NSString*   metaDataStringified         = [NSString stringWithFormat:@"\"%@\"", metaData];
        NSString*   stringToWrite               = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                                   startDateTimeStamp,
                                                   endDateTimeStamp,
                                                   healthKitType,
                                                   activityType,
                                                   totalDistance,
                                                   distanceUnit,
                                                   energyConsumed,
                                                   energyUnit,
                                                   quantitySource,
                                                   sourceIdentifier,
                                                   metaDataStringified];
        
        return stringToWrite;
    };
    
    NSString*(^CategoryDataSerializer)(id) = ^NSString*(id dataSample)
    {
        HKCategorySample*   catSample       = (HKCategorySample *)dataSample;
        NSString*           stringToWrite   = nil;
        
        if ([catSample.categoryType.identifier isEqualToString:@"HKCategoryTypeIdentifierSleepAnalysis"])
        {
            NSString*           startDateTime   = [catSample.startDate toStringInISO8601Format];
            NSString*           healthKitType   = catSample.sampleType.identifier;
            NSString*           categoryValue   = nil;
            
            if (catSample.value == HKCategoryValueSleepAnalysisAsleep)
            {
                categoryValue = @"HKCategoryValueSleepAnalysisAsleep";
            }
            else
            {
                categoryValue = @"HKCategoryValueSleepAnalysisInBed";
            }
            
            NSString*           quantityUnit        = [[HKUnit secondUnit] unitString];
            NSString*           sourceIdentifier    = catSample.source.bundleIdentifier;
            NSString*           quantitySource      = catSample.source.name;
            
            if (quantitySource == nil)
            {
                quantitySource = @"not available";
            }
            else if ([[[UIDevice currentDevice] name] isEqualToString:quantitySource])
            {
                if ([APCDeviceHardware platformString])
                {
                    quantitySource = [APCDeviceHardware platformString];
                }
                else
                {
                    //  This shouldn't get called.
                    quantitySource = @"iPhone";
                }
                
            }
            
            // Get the difference in seconds between the start and end date for the sample
            NSDateComponents* secondsSpentInBedOrAsleep = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond
                                                                                          fromDate:catSample.startDate
                                                                                            toDate:catSample.endDate
                                                                                           options:NSCalendarWrapComponents];
            NSString*           quantityValue   = [NSString stringWithFormat:@"%ld", (long)secondsSpentInBedOrAsleep.second];
            
            stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@\n",
                             startDateTime,
                             healthKitType,
                             categoryValue,
                             quantityValue,
                             quantityUnit,
                             sourceIdentifier,
                             quantitySource];
        }
        
        return stringToWrite;
    };
    
    NSArray* dataTypesWithReadPermission = self.initializationOptions[kHKReadPermissionsKey];
    
    // Just a note here that we are using n collectors to 1 data sink for quantity sample type data.
    NSArray*                    quantityColumnNames = @[@"startTime,endTime,type,value,unit,source,sourceIdentifier"];
    APCPassiveDataSink*         quantityreceiver    = [[APCPassiveDataSink alloc] initWithIdentifier:@"HealthKitDataCollector"
                                                                                         columnNames:quantityColumnNames
                                                                                  operationQueueName:@"APCHealthKitQuantity Activity Collector"
                                                                                    andDataProcessor:QuantityDataSerializer];
    
    NSArray*                    workoutColumnNames  = @[@"startTime,endTime,type,workoutType,total distance,unit,energy consumed,unit,source,sourceIdentifier,metadata"];
    APCPassiveDataSink*         workoutReceiver     = [[APCPassiveDataSink alloc] initWithIdentifier:@"HealthKitWorkoutCollector"
                                                                                         columnNames:workoutColumnNames
                                                                                  operationQueueName:@"APCHealthKitWorkout Activity Collector"
                                                                                    andDataProcessor:WorkoutDataSerializer];
    NSArray*                    categoryColumnNames = @[@"startTime,type,category value,value,unit,source,sourceIdentifier"];
    APCPassiveDataSink*         sleepReceiver       = [[APCPassiveDataSink alloc] initWithIdentifier:@"HealthKitSleepCollector"
                                                                                         columnNames:categoryColumnNames
                                                                                  operationQueueName:@"APCHealthKitSleep Activity Collector"
                                                                                    andDataProcessor:CategoryDataSerializer];
    
    if (dataTypesWithReadPermission)
    {
        for (id dataType in dataTypesWithReadPermission)
        {
            HKSampleType* sampleType = nil;
            
            if ([dataType isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* categoryType = (NSDictionary *) dataType;
                
                //Distinguish
                if (categoryType[kHKWorkoutTypeKey])
                {
                    sampleType = [HKObjectType workoutType];
                }
                else if (categoryType[kHKCategoryTypeKey])
                {
                    sampleType = [HKObjectType categoryTypeForIdentifier:categoryType[kHKCategoryTypeKey]];
                }
            }
            else
            {
                sampleType = [HKObjectType quantityTypeForIdentifier:dataType];
            }
            
            if (sampleType)
            {
                // This is really important to remember that we are creating as many user defaults as there are healthkit permissions here.
                NSString*                               uniqueAnchorDateName    = [NSString stringWithFormat:@"APCHealthKit%@AnchorDate", dataType];
                APCHealthKitBackgroundDataCollector*    collector               = [[APCHealthKitBackgroundDataCollector alloc] initWithIdentifier:sampleType.identifier
                                                                                                                                       sampleType:sampleType anchorName:uniqueAnchorDateName
                                                                                                                                 launchDateAnchor:LaunchDate];
                
                //If the HKObjectType is a HKWorkoutType then set a different receiver/data sink.
                if ([sampleType isKindOfClass:[HKWorkoutType class]])
                {
                    [collector setReceiver:workoutReceiver];
                    [collector setDelegate:workoutReceiver];
                }
                else if ([sampleType isKindOfClass:[HKCategoryType class]])
                {
                    [collector setReceiver:sleepReceiver];
                    [collector setDelegate:sleepReceiver];
                }
                else
{
                    [collector setReceiver:quantityreceiver];
                    [collector setDelegate:quantityreceiver];
                }
                
                [collector start];
                [self.passiveDataCollector addDataSink:collector];
            }
        }
    }
}

/*********************************************************************************/
#pragma mark - APCOnboardingDelegate Methods
/*********************************************************************************/

- (APCScene *)inclusionCriteriaSceneForOnboarding:(APCOnboarding *)__unused onboarding
{
    APCScene *scene = [APCScene new];
    scene.name = @"APHInclusionCriteriaViewController";
    scene.storyboardName = @"APHOnboarding";
    scene.bundle = [NSBundle mainBundle];
    
    return scene;
}


/*********************************************************************************/
#pragma mark - Consent
/*********************************************************************************/

- (ORKTaskViewController *)consentViewController
{
    APHBooleanQuestionStep* question1Step      = [[APHBooleanQuestionStep alloc]initWithIdentifier:@"question1" tag:1];
    question1Step.answer = true;
    APHBooleanQuestionStep* question2Step      = [[APHBooleanQuestionStep alloc]initWithIdentifier:@"question2" tag:2];
    question2Step.answer = true;
    APHBooleanQuestionStep* question3Step      = [[APHBooleanQuestionStep alloc]initWithIdentifier:@"question3" tag:3];
    question3Step.answer = true;
    ORKStep*                quizEvaluationStep = [[ORKStep alloc]initWithIdentifier:@"quizEvaluation"];
    
    NSArray*                        customSteps = @[question1Step, question2Step, question3Step, quizEvaluationStep];
    APCConsentTask*                 consentTask = [[APCConsentTask alloc] initWithIdentifier:@"consent"
                                                                          propertiesFileName:kConsentPropertiesFileName
                                                                                 customSteps:customSteps];
    APHConsentTaskViewController*   consentVC   = [[APHConsentTaskViewController alloc] initWithTask:consentTask
                                                                                         taskRunUUID:[NSUUID UUID]];
    
    APHConsentRedirector*   consentRedirector = [[APHConsentRedirector alloc] init];
    consentRedirector.failureCount      = 0;
    consentRedirector.maxAllowedFailure = 2;
    
    consentVC.consentRedirector  = consentRedirector;
    consentTask.redirector       = consentRedirector;
    consentTask.failedMessageTag = @"quizEvaluation";
    
    return consentVC;
}

@end
