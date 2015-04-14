// 
//  APHTableViewDashboardAQAlertItem.h 
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
 
#import <Foundation/Foundation.h>
#import "APHTableViewItem.h"

typedef NS_ENUM(NSUInteger, APHAirQualityRowType) {
    kAPHAirQualityRowTypeOzone = 0,
    kAPHAirQualityRowTypeSmallParticles,
    kAPHAirQualityRowTypeBigParticles,
    kAPHAirQualityRowTypeAQI,
};

@interface APHTableViewDashboardAQAlertItem : APCTableViewDashboardItem

@property (nonatomic, strong) NSDictionary * aqiDictionary;
@property (nonatomic, strong) NSString * locationName;
//today values
@property (nonatomic, strong) NSNumber * PM25;
@property (nonatomic, strong) NSNumber * PM10;
@property (nonatomic, strong) NSNumber * ozone;
@property (nonatomic, strong) NSString * airQuality;
//tomorrow values
@property (nonatomic, strong) NSNumber * PM25_tomorrow;
@property (nonatomic, strong) NSNumber * PM10_tomorrow;
@property (nonatomic, strong) NSNumber * ozone_tomorow;
@property (nonatomic, strong) NSString * airQuality_tomorrow;

@property (nonatomic, strong) NSString * PM25String;
@property (nonatomic, strong) NSString * discussion;
@property (nonatomic, strong) NSString * actionDay;
@property (nonatomic, strong) UIColor * alertColor;
@property (nonatomic, strong) UIColor * alertColor_tomorrow;

@property (nonatomic) BOOL showTomorrowInfo;

@end
