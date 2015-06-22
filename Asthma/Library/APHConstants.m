// 
//  APHConstants.m 
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
 
#import "APHConstants.h"

NSString * const kPeakFlowKey = @"PeakFlow";
NSString * const kDaytimeSickKey = @"DaytimeSick";
NSString * const kNighttimeSickKey = @"NighttimeSick";
NSString * const kQuickReliefKey= @"QuickRelief";
NSString * const kTookMedicineKey = @"TookMedicine";
NSString * const kMissWorkDailyKey = @"MissWorkDaily";

NSString * const kSteroid1Key = @"Steroid1";
NSString * const kSteroid2Key = @"Steroid2";
NSString * const kVisit1Key = @"Visit1";
NSString * const kVisit2Key = @"Visit2";
NSString * const kSideEffectKey = @"SideEffect";
NSString * const kMissWorkKey = @"MissWork";
NSString * const kDaysMissedKey = @"MissedDay:";

//Survey identifiers
NSString * const kDailySurveyTaskID = @"DailyPrompt-27829fa5-d731-4372-ba30-a5859f655297";
NSString * const kWeeklySurveyTaskID = @"WeeklySurvey-b573a78-8917-4582-8f1f-0552d0bfd28a";
NSString * const kAboutYouSurveyTaskID = @"AboutYou-27829fa5-d731-4372-ba30-a5859f688297";
NSString * const kMedicalHistorySurveyTaskID = @"MedicalHistory-b3cd0d66-b943-11e4-a71e-12e3f512a338";
NSString * const kMedicationSurveyTaskID = @"AsthmaMedication-c2379e84-b943-11e4-a71e-12e3f512a338";
NSString * const kYourAsthmaSurveyTaskID = @"YourAsthma-cc06cd68-b943-11e4-a71e-12e3f512a338";
NSString * const kAsthmaHistorySurveyTaskID = @"AsthmaHistory-d6d07ba4-b943-11e4-a71e-12e3f512a338";
NSString * const kEnrollmentSurveyTaskID = @"APHEnrollmentForRecontactTaskViewController-1E174065-5B02-11E4-8ED6-0800200C9A66";

NSString * const kSteroid1StepIdentifier = @"asthma_medicine";
NSString * const kSteroid2StepIdentifier = @"prednisone";
NSString * const kVisit1StepIdentifier = @"emergency_room";
NSString * const kVisit2StepIdentifier = @"admission";
NSString * const kSideEffectStepIdentifier = @"side_effects";
NSString * const kMissWorkStepIdentifier = @"missed_work";
NSString * const kDaysMissedStepIdentifier = @"missed_work_days";

NSString * const kMinorSideEffectValue = @"2";
NSString * const kMajorSideEffectValue = @"3";

@implementation APHConstants

@end
