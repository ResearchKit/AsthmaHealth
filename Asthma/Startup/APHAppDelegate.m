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
static NSInteger const kExpectedNumOfCompInScheduleStr  = 5;
static NSString *const kConsentPropertiesFileName       = @"APHConsentSection";

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
    NSString*       previousVersionKey  = @"previousVersion";
    NSDictionary*   infoDictionary      = [[NSBundle mainBundle] infoDictionary];
    NSString*       majorVersion        = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString*       minorVersion        = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSUserDefaults* defaults            = [NSUserDefaults standardUserDefaults];
    NSError*        migrationError      = nil;
    
    if ([self doesPersisteStoreExist] == NO)
    {
        APCLogEvent(@"This application is being launched for the first time. We know this because there is no persistent store.");
    }
    else if ( [defaults objectForKey:previousVersionKey] == nil)
    {
        APCLogEvent(@"The entire data model version %d", kTheEntireDataModelOfTheApp);
        if (![self performMigrationFromOneToTwoWithError:&migrationError])
        {
            APCLogEvent(@"Migration from version 1 to 2 has failed.");
        }

        if (![self performMigrationFromTwoToThreeWithError:&migrationError])
        {
            APCLogEvent(@"Migration from version %@ to %@ has failed.", [defaults objectForKey:previousVersionKey], @(kTheEntireDataModelOfTheApp));
        }
    }
    else if ([[defaults objectForKey:previousVersionKey] isEqual: @2])
    {
        APCLogEvent(@"The entire data model version %d", kTheEntireDataModelOfTheApp);
        if (![self performMigrationFromTwoToThreeWithError:&migrationError])
        {
            APCLogEvent(@"Migration from version %@ to %@ has failed.", [defaults objectForKey:previousVersionKey], @(kTheEntireDataModelOfTheApp));
        }
    }
    
    [defaults setObject:majorVersion
                 forKey:@"shortVersionString"];
    
    [defaults setObject:minorVersion
                 forKey:@"version"];
    

    if (!migrationError)
    {
        [defaults setObject:@(currentVersion) forKey:previousVersionKey];
    }

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
    
    [self.tasksReminder manageTaskReminder:dailySurveyReminder];
    [self.tasksReminder manageTaskReminder:weeklySurveyReminder];
    [self.tasksReminder manageTaskReminder:medicationReminder];
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
                                                 @"AboutYou-27829fa5-d731-4372-ba30-a5859f688297" : [UIColor appTertiaryPurpleColor]
                                                 }];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName : [UIColor appSecondaryColor1],
                                                            NSFontAttributeName : [UIFont appNavBarTitleFont]
                                                            }];
    
    [[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
    
    self.dataSubstrate.parameters.bypassServer = YES;
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
-(void)setUpCollectors
{
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
