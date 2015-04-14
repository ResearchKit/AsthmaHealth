// 
//  APHTableViewDashboardAQAlertItem.m 
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
 
#import "APHTableViewDashboardAQAlertItem.h"
@import APCAppCore;

NSString * kResultsKey = @"results";
NSString * kReportsKey = @"reports";
NSString * kReportsTypeKey = @"report_type";
NSString * kReportDataTypeKey = @"data_type";
NSString * kReportsTypeValue = @"PM2.5";
NSString * kValidDateKey = @"valid_date";
NSString * kPrimaryKey = @"primary";
NSString * kAQIValueKey = @"aqi_value";
NSString * kDiscussionKey = @"discussion";
NSString * kAQICategoryKey = @"aqi_category";
NSString * kActionDayKey = @"action_day";
NSString * kReportingArea = @"reporting_area";
NSString * kStateCode = @"state_code";

@implementation APHTableViewDashboardAQAlertItem

static NSString *kDataNotAvailable = @"N/A";

-(id)init{
    self = [super init];
    _showTomorrowInfo = NO;
    return self;
}

- (void)setAqiDictionary:(NSDictionary *)aqiDictionary
{
    _aqiDictionary = aqiDictionary;
    [self processDictionary: aqiDictionary];
}

- (NSString*) locationName
{
    if (!_locationName) {
        _locationName = @"Unknown";
    }
    return _locationName;
}

- (NSString *)airQuality
{
    if (!_airQuality) {
        _airQuality = kDataNotAvailable;
    }
    return _airQuality;
}

- (NSString*) PM25String
{
    if (self.PM25 && [self.PM25 doubleValue] != 0) {
        _PM25String = [self.PM25 stringValue];
    }
    else
    {
        _PM25String = kDataNotAvailable;
    }
    return _PM25String;
}

- (NSString *)discussion
{
    if (!_discussion) {
        _discussion = kDataNotAvailable;
    }
    return _discussion;
}

- (NSString *)actionDay
{
    if (!_actionDay) {
        _actionDay = kDataNotAvailable;
    }
    return _actionDay;
}

- (UIColor *)alertColor
{
    if (!_alertColor) {
        _alertColor = [UIColor appTertiaryRedColor];
    }
    return _alertColor;
}

- (UIColor *)alertColor_tomorrow
{
    if (!_alertColor_tomorrow) {
        _alertColor_tomorrow = [UIColor appTertiaryRedColor];
    }
    return _alertColor_tomorrow;
}

- (void) processDictionary: (NSDictionary*) dict
{
    NSArray * reports = [[dict objectForKey:kResultsKey] objectForKey:kReportsKey];
    
    //Extract today's actual and tomorrow's forecast (data_type == F) for Ozone, Small Particles, Big Particles, and Air Quality
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    NSString * validTodayDateExpected = [dateFormatter stringFromDate:[NSDate todayAtMidnight]];
    NSString * validTomorrowDateExpected = [dateFormatter stringFromDate:[NSDate tomorrowAtMidnight]];
    
    //Actuals - use Observed first, then Forecast if no observed data available
    NSSortDescriptor *reportDateDescriptor = [[NSSortDescriptor alloc] initWithKey:kValidDateKey ascending:YES];
    NSSortDescriptor *dataTypeDescriptor = [[NSSortDescriptor alloc] initWithKey:kReportDataTypeKey ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:reportDateDescriptor, dataTypeDescriptor, nil];
    NSArray *sortedReports = [reports sortedArrayUsingDescriptors:sortDescriptors];
    
    //note: dictionaries may contain <null> values
    for (NSDictionary *report in sortedReports) {
        if ([[report objectForKey:kValidDateKey] isEqualToString:validTodayDateExpected]) {
            
            if ([[report objectForKey:kReportsTypeKey] isEqualToString:@"OZONE"]) {
                if (!_ozone || [_ozone  isEqual: @0]) {
                    _ozone = [[report objectForKey:kAQIValueKey] isKindOfClass:[NSNull class]] ? @0 : [report objectForKey:kAQIValueKey];
                }
            }
            
            if ([[report objectForKey:kReportsTypeKey] isEqualToString:@"PM2.5"]) {
                if (!_PM25 || [_PM25 isEqual:@0]) {
                    _PM25 = [[report objectForKey:kAQIValueKey] isKindOfClass:[NSNull class]] ? @0 : [report objectForKey:kAQIValueKey];
                }
            }
            
            if ([[report objectForKey:kReportsTypeKey] isEqualToString:@"PM10"]) {
                if (!_PM10 || [_PM10 isEqual:@0]) {
                    _PM10 = [[report objectForKey:kAQIValueKey] isKindOfClass:[NSNull class]] ? @0 : [report objectForKey:kAQIValueKey];
                }
            }
            
            if ([report objectForKey:kReportsTypeKey]) {
                if (!_airQuality || [_airQuality isEqual:@0]) {
                    _airQuality = [[report objectForKey:kAQICategoryKey] isKindOfClass:[NSNull class]] ? @0 : [report objectForKey:kAQICategoryKey];
                }
            }
            
            NSNumber *pmValue = [report objectForKey:kAQIValueKey] ? [report objectForKey:kAQIValueKey] : @0;
            if (![pmValue isKindOfClass:[NSNull class]]) {
                if (NSLocationInRange(pmValue.doubleValue, NSMakeRange(0, 51))) {
                    _alertColor = [UIColor appTertiaryGreenColor];
                }
                else if (NSLocationInRange(pmValue.doubleValue, NSMakeRange(51, 150)))
                {
                    _alertColor = [UIColor appTertiaryYellowColor];
                }
                else if (pmValue.doubleValue >=200)
                {
                    _alertColor = [UIColor appTertiaryRedColor];
                }
            }
        }
  
        else if ([[report objectForKey:kValidDateKey] isEqualToString:validTomorrowDateExpected]&& [[report objectForKey:kReportDataTypeKey] isEqualToString:@"F"]){
            //Forecasts
            if ([[report objectForKey:kReportsTypeKey] isEqualToString:@"OZONE"]) {
                _ozone_tomorow = [[report objectForKey:kAQIValueKey] isKindOfClass:[NSNull class]] ? @0 : [report objectForKey:kAQIValueKey];
            }
            if ([[report objectForKey:kReportsTypeKey] isEqualToString:@"PM2.5"]) {
                _PM25_tomorrow = [[report objectForKey:kAQIValueKey] isKindOfClass:[NSNull class]] ? @0 : [report objectForKey:kAQIValueKey];
            }
            if ([[report objectForKey:kReportsTypeKey] isEqualToString:@"PM10"]) {
                _PM10_tomorrow = [[report objectForKey:kAQIValueKey] isKindOfClass:[NSNull class]] ? @0 : [report objectForKey:kAQIValueKey];
            }
            if ([report objectForKey:kReportsTypeKey]) {
                _airQuality_tomorrow = [[report objectForKey:kAQICategoryKey] isKindOfClass:[NSNull class]] ? @0 : [report objectForKey:kAQICategoryKey];
            }
            
            NSNumber *pmValue = [report objectForKey:kAQIValueKey] ? [report objectForKey:kAQIValueKey] : @0;
            if (![pmValue isKindOfClass:[NSNull class]]) {
                if (NSLocationInRange(pmValue.doubleValue, NSMakeRange(0, 51))) {
                    _alertColor_tomorrow = [UIColor appTertiaryGreenColor];
                }
                else if (NSLocationInRange(pmValue.doubleValue, NSMakeRange(51, 150)))
                {
                    _alertColor_tomorrow = [UIColor appTertiaryYellowColor];
                }
                else if (pmValue.doubleValue >=200)
                {
                    _alertColor_tomorrow = [UIColor appTertiaryRedColor];
                }
            }
        }
    }
    
    NSMutableArray * locationNames = [NSMutableArray array];
    NSString * reportingArea = dict[kResultsKey][kReportingArea];
    if (reportingArea != nil) {
        [locationNames addObject:reportingArea];
    }
    NSString * stateCode = dict[kResultsKey][kStateCode];
    if (stateCode != nil) {
        [locationNames addObject:stateCode];
    }
    self.locationName = [locationNames componentsJoinedByString:@", "];

}



@end
