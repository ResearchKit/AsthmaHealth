//
//  APHDashboardViewController.m
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

#import "APHDashboardViewController.h"
#import "APHDashboardEditViewController.h"
#import "APHDashboardAirQualityTableViewCell.h"
#import "APHAirQualityCollectionViewCell.h"
#import "APHTableViewDashboardAQAlertItem.h"
#import "APHAsthmaBadgesObject.h"
#import "APHDashboardBadgesTableViewCell.h"
#import "APHBadgesCollectionViewCell.h"
#import "APHCalendarCollectionViewController.h"
#import "APHAirQualitySectionHeaderView.h"
#import "APHCalendarDataModel.h"
#import "APHAirQualityDataModel.h"
#import "APHConstants.h"
#import "APHAppDelegate.h"

static NSString *kTooltipBadgesContent = @"As you complete daily surveys, work without asthma interruption, and achieve asthma-free nights and days, you'll earn badges for succeeding five of the last seven days. Tap item to see calendar view.";
static NSString *kTooltipStepsContent = @"This graph shows the number of steps you have taken each day, as recorded by your phone or connected device. Tap the button in the upper right corner to make the graph larger.";
static NSString *kTooltipPeakFlowContent = @"This graph shows your daily peak flow values, from your daily surveys or a connected device. Tap the button in the upper right corner to make the graph larger.";
static NSString *kTooltipSymptomControlContent = @"This graph shows you how well your asthma symptoms are being controlled, based on the information you provide in your daily and weekly surveys.";
static NSString *kTooltipAirQualityContent = @"The AQI is an index for reporting daily air quality. It tells you how clean or polluted your air is, and what associated health effects might be a concern for you. AQI data provided by U.S. EPA AirNow";

@import APCAppCore;

static NSString * const kAPCBasicTableViewCellIdentifier       = @"APCBasicTableViewCell";
static NSString * const kAPCRightDetailTableViewCellIdentifier = @"APCRightDetailTableViewCell";

static NSInteger const kCollectionViewsBaseTag = 101;
static NSInteger const kNumberOfItemsForBadges = 4;
static CGFloat const kBadgesCollectionViewCellHeight = 54.0f;

NSString *const kDataNotAvailable = @"N/A";

@interface APHDashboardViewController ()<UIViewControllerTransitioningDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, APCPieGraphViewDatasource, APCConcentricProgressViewDataSource, APHAirQualityReportReceiver>

@property (nonatomic, strong) NSMutableArray *rowItemsOrder;

@property (nonatomic, strong) APCScoring *stepScore;
@property (nonatomic, strong) APCScoring *peakScore;

@property (nonatomic, strong) APHAsthmaBadgesObject * badgeObject;
@property (nonatomic, strong) APHCalendarDataModel *calendarDataModel;
@property (nonatomic, assign) BOOL shouldAnimateObjects;

//Air Quality
@property (nonatomic, strong) APHTableViewDashboardAQAlertItem * aqiObject;
@property (nonatomic, assign) float numberOfItemsForAirQuality;
@property (nonatomic, assign) float airQualityCollectionViewCellHeight;
@property (nonatomic, assign) float airQualityCollectionViewHeaderHeight;

@end

@implementation APHDashboardViewController

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
        
        if (!_rowItemsOrder.count) {
            _rowItemsOrder = [[NSMutableArray alloc] initWithArray:@[
                                                                     @(kAPHDashboardItemTypeAsthmaControl),
                                                                     @(kAPHDashboardItemTypeAlerts),
                                                                     @(kAPHDashboardItemTypeBadges),
                                                                     @(kAPHDashboardItemTypeSteps),
                                                                     @(kAPHDashboardItemTypePeakFlow)
                                                                     ]];
            
            [defaults setObject:[NSArray arrayWithArray:_rowItemsOrder] forKey:kAPCDashboardRowItemsOrder];
            [defaults synchronize];
            
        }
        
        self.title = NSLocalizedString(@"Dashboard", @"Dashboard");
    }
    
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //calendar
    self.calendarDataModel = [[APHCalendarDataModel alloc]init];
    //air quality properties to be updated on notification from APHAirQualityDataModel
    
    self.numberOfItemsForAirQuality = 0;
    self.airQualityCollectionViewCellHeight = 0.0f;
    self.airQualityCollectionViewHeaderHeight = 0.0f;
    self.aqiObject = [APHTableViewDashboardAQAlertItem new];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.rowItemsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kAPCDashboardRowItemsOrder]];
    self.badgeObject = [APHAsthmaBadgesObject new];
    self.shouldAnimateObjects = NO;
    
    //get aqi if exists
    __weak APHAirQualityDataModel *airQualityDataModel = [(APHAppDelegate *)[UIApplication sharedApplication].delegate airQualityDataModel];
    airQualityDataModel.airQualityReportReceiver = self;
    if (airQualityDataModel.aqiObject) {
        [self airQualityModel:airQualityDataModel didDeliverAirQualityAlert:airQualityDataModel.aqiObject];
    }
    
    [self prepareScoringObjects];
    [self prepareData];
}

- (void)prepareScoringObjects
{
    {
        HKQuantityType *hkQuantity = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        self.stepScore = [[APCScoring alloc] initWithHealthKitQuantityType:hkQuantity
                                                                      unit:[HKUnit countUnit]
                                                              numberOfDays:-kNumberOfDaysToDisplay];
    }
    
    {
        self.peakScore = [[APCScoring alloc] initWithTask:kDailySurveyTaskID
                                             numberOfDays:-kNumberOfDaysToDisplay
                                                 valueKey:kPeakFlowKey
                                                  dataKey:nil
                                                  sortKey:nil
                                                  groupBy:APHTimelineGroupDay];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Data

- (void)prepareData
{
    
    [self.items removeAllObjects];
    
    {
        NSMutableArray *rowItems = [NSMutableArray new];
        
        NSUInteger allScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.countOfTotalRequiredTasksForToday;
        NSUInteger completedScheduledTasks = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.countOfTotalCompletedTasksForToday;
        
        {
            APCTableViewDashboardProgressItem *item = [APCTableViewDashboardProgressItem new];
            item.identifier = kAPCDashboardProgressTableViewCellIdentifier;
            item.editable = NO;
            item.progress = (CGFloat)completedScheduledTasks/allScheduledTasks;
            item.caption = NSLocalizedString(@"Activity Completion", @"Activity Completion");
            item.info = NSLocalizedString(@"Check the Activities tab to see today's surveys.  Finish them all to get 100% Activity Completion.", @"");
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = item;
            row.itemType = kAPCTableViewDashboardItemTypeProgress;
            [rowItems addObject:row];
        }
        
        for (NSNumber *typeNumber in self.rowItemsOrder) {
            
            APHDashboardItemType rowType = typeNumber.integerValue;
            
            switch (rowType) {
                case kAPHDashboardItemTypeSteps:
                {
                    APCTableViewDashboardGraphItem *item = [APCTableViewDashboardGraphItem new];
                    item.caption = NSLocalizedString(@"Steps", @"");
                    item.graphData = self.stepScore;
                    if (self.stepScore.averageDataPoint.doubleValue > 0 && self.stepScore.averageDataPoint.doubleValue != self.stepScore.maximumDataPoint.doubleValue) {
                        item.detailText = [NSString stringWithFormat:NSLocalizedString(@"Average : %0.0f Steps", @"Average: {value} ft"), [[self.stepScore averageDataPoint] doubleValue]];
                    }
                    item.identifier = kAPCDashboardGraphTableViewCellIdentifier;
                    item.editable = YES;
                    item.tintColor = [UIColor appTertiaryPurpleColor];
                    item.info = NSLocalizedString(kTooltipStepsContent, @"");
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                    
                }
                    break;
                case kAPHDashboardItemTypePeakFlow:{
                    
                    APCTableViewDashboardGraphItem *item = [APCTableViewDashboardGraphItem new];
                    item.caption = NSLocalizedString(@"Peak Flow", @"");
                    if (self.peakScore.averageDataPoint.doubleValue > 0 && self.peakScore.averageDataPoint.doubleValue != self.peakScore.maximumDataPoint.doubleValue) {
                        item.detailText = [NSString stringWithFormat:NSLocalizedString(@"Average : %0.0f", @"Average: {value} ft"), [[self.peakScore averageDataPoint] doubleValue]];
                    }
                    item.graphData = self.peakScore;
                    item.identifier = kAPCDashboardGraphTableViewCellIdentifier;
                    item.editable = YES;
                    item.tintColor = [UIColor appTertiaryYellowColor];
                    item.info = NSLocalizedString(kTooltipPeakFlowContent, @"");
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;
                case kAPHDashboardItemTypeBadges:{
                    APHTableViewDashboardBadgesItem *item = [APHTableViewDashboardBadgesItem new];
                    item.caption = NSLocalizedString(@"Badges", @"");
                    item.identifier = kAPHDashboardBadgesTableViewCellIdentifier;
                    item.tintColor = [UIColor appTertiaryGreenColor];
                    item.editable = YES;
                    
                    item.dailyParticipationPercent = self.badgeObject.completionValue;
                    item.workAttendancePercent = self.badgeObject.workAttendanceValue;
                    item.undisturbedNightsPercent =self.badgeObject.undisturbedNightsValue;
                    item.asthmaFreeDaysPercent = self.badgeObject.asthmaFreeDaysValue;
                    item.info = NSLocalizedString(kTooltipBadgesContent, @"");
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;
                case kAPHDashboardItemTypeAsthmaControl:{
                    APCTableViewDashboardAsthmaControlItem *item = [APCTableViewDashboardAsthmaControlItem new];
                    item.caption = NSLocalizedString(@"Asthma Symptom Control", @"");
                    item.identifier = kAPCDashboardPieGraphTableViewCellIdentifier;
                    item.tintColor = [UIColor appTertiaryRedColor];
                    item.editable = YES;
                    item.info = NSLocalizedString(kTooltipSymptomControlContent, @"");
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                }
                    break;
                case kAPHDashboardItemTypeAlerts:{
                    
                    APHTableViewDashboardAQAlertItem *item = self.aqiObject;
                    item.identifier = kAPHDashboardAirQualityTableViewCellIdentifier;
                    item.caption = NSLocalizedString(@"Air Quality Near You", @"");
                    item.detailText = self.aqiObject.locationName ? self.aqiObject.locationName : @"Unknown";
                    item.editable = YES;
                    item.tintColor = [UIColor appTertiaryBlueColor];
                    item.info = NSLocalizedString(kTooltipAirQualityContent, @"");
                    
                    APCTableViewRow *row = [APCTableViewRow new];
                    row.item = item;
                    row.itemType = rowType;
                    [rowItems addObject:row];
                    
                }
                    break;
                default:
                    break;
            }
            
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        section.sectionTitle = NSLocalizedString(@"Recent Activity", @"");
        [self.items addObject:section];
    }
    
    [self.tableView reloadData];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    APCTableViewDashboardItem *dashboardItem = (APCTableViewDashboardItem *)[self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardAQAlertItem class]]) {
        APHDashboardAirQualityTableViewCell *alertsCell = (APHDashboardAirQualityTableViewCell *)cell;
        alertsCell.delegate = self;
        alertsCell.collectionView.delegate = self;
        alertsCell.collectionView.dataSource = self;
        alertsCell.collectionView.tag = kCollectionViewsBaseTag + indexPath.row;
        alertsCell.airQualityLocationLabel.text = self.aqiObject.locationName;
        alertsCell.textLabel.text = @"";
        alertsCell.title = dashboardItem.caption;
        alertsCell.tintColor = dashboardItem.tintColor;
        [alertsCell.collectionView reloadData];
        
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardBadgesItem class]]) {
        
        APHTableViewDashboardBadgesItem *badgeItem = (APHTableViewDashboardBadgesItem *)dashboardItem;
        
        APHDashboardBadgesTableViewCell *badgeCell = (APHDashboardBadgesTableViewCell *)cell;
        badgeCell.delegate = self;
        badgeCell.concentricProgressView.datasource = self;
        badgeCell.textLabel.text = @"";
        badgeCell.title = badgeItem.caption;
        badgeCell.tintColor = badgeItem.tintColor;
        
        badgeCell.collectionView.delegate = self;
        badgeCell.collectionView.dataSource = self;
        badgeCell.collectionView.tag = kCollectionViewsBaseTag + indexPath.row;
        [badgeCell.collectionView reloadData];
        if (self.shouldAnimateObjects) {
            [badgeCell.concentricProgressView setNeedsLayout];
        }
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardAsthmaControlItem class]]){
        APCTableViewDashboardAsthmaControlItem *asthmaItem = (APCTableViewDashboardAsthmaControlItem *)dashboardItem;
        
        APCDashboardPieGraphTableViewCell *pieGraphCell = (APCDashboardPieGraphTableViewCell *)cell;
        pieGraphCell.delegate = self;
        pieGraphCell.pieGraphView.datasource = self;
        pieGraphCell.textLabel.text = @"";
        pieGraphCell.title = asthmaItem.caption;
        pieGraphCell.tintColor = asthmaItem.tintColor;
        if (self.shouldAnimateObjects) {
            [pieGraphCell.pieGraphView setNeedsLayout];
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardAQAlertItem class]]) {
        NSInteger multiplier = self.aqiObject.showTomorrowInfo ? 2 : 1;
        
        height = 66 + (self.numberOfItemsForAirQuality * self.airQualityCollectionViewCellHeight * multiplier) + (self.airQualityCollectionViewHeaderHeight * 2);
        
    }else if ([dashboardItem isKindOfClass:[APHTableViewDashboardBadgesItem class]]){
        
        height = 179;
        
        height += (kNumberOfItemsForBadges*kBadgesCollectionViewCellHeight);
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardAsthmaControlItem class]]){
        height = 259.0f;
    }
    
    return height;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = 1;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(collectionView.tag - kCollectionViewsBaseTag) inSection:0];
    
    APCTableViewDashboardItem *dashboardItem = (APCTableViewDashboardItem *)[self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardAQAlertItem class]]) {
        count = 2; //Today + Tomorrow
    }
    
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(collectionView.tag - kCollectionViewsBaseTag) inSection:0];
    
    APCTableViewDashboardItem *dashboardItem = (APCTableViewDashboardItem *)[self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardAQAlertItem class]]) {
        count = self.numberOfItemsForAirQuality;
        
        if (section == 1 && !self.aqiObject.showTomorrowInfo) {
            count = 0;
        }
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardBadgesItem class]]){
        count = kNumberOfItemsForBadges;
    }
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForRow:(collectionView.tag - kCollectionViewsBaseTag) inSection:0];
    
    APCTableViewDashboardItem *dashboardItem = (APCTableViewDashboardItem *)[self itemForIndexPath:itemIndexPath];
    
    UICollectionViewCell *cell;
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardAQAlertItem class]]) {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAPHAirQualityCollectionViewCellIdentifier forIndexPath:indexPath];
        
        APHAirQualityCollectionViewCell *alertCell = (APHAirQualityCollectionViewCell *)cell;
        alertCell.textLabel.text = nil;
        alertCell.detailTextLabel.text = nil;
        alertCell.imageView.image = nil;
        
        switch (indexPath.row) {
            case kAPHAirQualityRowTypeOzone:
            {
                alertCell.textLabel.text = NSLocalizedString(@"Ozone", @"");
                
                NSString *valueString = (indexPath.section == 0) ? self.aqiObject.ozone.stringValue : self.aqiObject.ozone_tomorow.stringValue;
                
                alertCell.detailTextLabel.text =  valueString ? valueString : kDataNotAvailable;
                
                alertCell.detailTextLabel.textColor = self.aqiObject.alertColor;
                alertCell.detailTextLabel.textColor = (indexPath.section == 0) ? self.aqiObject.alertColor : self.aqiObject.alertColor_tomorrow;
                
                alertCell.imageView.image = [UIImage imageNamed:@"icon_ozone"];
            }
                break;
            case kAPHAirQualityRowTypeSmallParticles:
            {
                NSMutableAttributedString *subscriptedString = [[NSMutableAttributedString alloc] initWithString:@" 2.5"];
                [subscriptedString addAttribute:NSFontAttributeName
                                          value:[UIFont fontWithName:alertCell.textLabel.font.fontName size:alertCell.textLabel.font.pointSize/1.5]
                                          range:NSMakeRange(1, 3)];
                
                [subscriptedString addAttribute:@"NSBaselineOffset"
                                          value:[NSNumber numberWithFloat:-(alertCell.textLabel.font.pointSize*1/3)]
                                          range:NSMakeRange(1, 3)];
                
                NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:@"Small Particles PM"];
                [finalString appendAttributedString:subscriptedString];
                alertCell.textLabel.attributedText = finalString;
                
                NSString *valueString = (indexPath.section == 0) ? self.aqiObject.PM25String : self.aqiObject.PM25_tomorrow.stringValue;
                
                alertCell.detailTextLabel.text =  valueString ? valueString : kDataNotAvailable;
                alertCell.detailTextLabel.textColor = (indexPath.section == 0) ? self.aqiObject.alertColor : self.aqiObject.alertColor_tomorrow;
                alertCell.imageView.image = [UIImage imageNamed:@"icon_smallParticles"];
            }
                break;
            case kAPHAirQualityRowTypeBigParticles:
            {
                NSMutableAttributedString *subscriptedString = [[NSMutableAttributedString alloc] initWithString:@" 10"];
                [subscriptedString addAttribute:NSFontAttributeName
                                          value:[UIFont fontWithName:alertCell.textLabel.font.fontName size:alertCell.textLabel.font.pointSize/1.5]
                                          range:NSMakeRange(1, 2)];
                
                [subscriptedString addAttribute:@"NSBaselineOffset"
                                          value:[NSNumber numberWithFloat:-(alertCell.textLabel.font.pointSize*1/3)]
                                          range:NSMakeRange(1, 2)];
                
                NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:@"Big Particles PM"];
                [finalString appendAttributedString:subscriptedString];
                
                alertCell.textLabel.attributedText = finalString;
                
                NSString *valueString = (indexPath.section == 0) ? self.aqiObject.PM10.stringValue : self.aqiObject.PM10_tomorrow.stringValue;
                
                alertCell.detailTextLabel.text =  valueString ? valueString : kDataNotAvailable;
                alertCell.detailTextLabel.textColor = (indexPath.section == 0) ? self.aqiObject.alertColor : self.aqiObject.alertColor_tomorrow;
                alertCell.imageView.image = [UIImage imageNamed:@"icon_bigParticles"];
            }
                break;
            case kAPHAirQualityRowTypeAQI:
            {
                alertCell.textLabel.text = NSLocalizedString(@"Air Quality Index", @"");
                NSString *valueString = (indexPath.section == 0) ? self.aqiObject.airQuality : self.aqiObject.airQuality_tomorrow;
                
                alertCell.detailTextLabel.text =  valueString ? valueString : kDataNotAvailable;
                alertCell.detailTextLabel.textColor = (indexPath.section == 0) ? self.aqiObject.alertColor : self.aqiObject.alertColor_tomorrow;
                alertCell.imageView.image = [UIImage imageNamed:@"icon_airQuality"];
            }
                break;
            default:
                break;
        }
        
    } else if ([dashboardItem isKindOfClass:[APHTableViewDashboardBadgesItem class]]){
        APHBadgesCollectionViewCell *badgeCell = [collectionView dequeueReusableCellWithReuseIdentifier:kAPHBadgesCollectionViewCellIdentifier forIndexPath:indexPath];
        badgeCell.imageView.image = [UIImage imageNamed:@"icon_trophy_empty"];
        badgeCell.tintView.backgroundColor = [UIColor appTertiaryGreenColor];
        CGFloat percent = 0.0;
        switch (indexPath.row) {
                
            case kAPHBadgesRowTypeDailyParticipation:
            {
                badgeCell.textLabel.text = NSLocalizedString(@"Survey Completion", @"");
                percent = self.badgeObject.completionValue;
                badgeCell.detailTextLabel.text = [NSString stringWithFormat:@"%2.0f%%", percent *100];
                badgeCell.detailTextLabel.textColor = [UIColor appTertiaryBlueColor];
                if (percent > 0.60) {
                    badgeCell.imageView.image = [UIImage imageNamed:@"icon_trophy_blue"];
                }
                if (percent > 0.85){
                    badgeCell.imageView.image = [UIImage imageNamed:@"icon_trophy_blue_crown"];
                }
            }
                break;
            case kAPHBadgesRowTypeWorkAttendance:
            {
                badgeCell.textLabel.text = NSLocalizedString(@"Work Attendance", @"");
                percent = self.badgeObject.workAttendanceValue;
                if (percent >= 0) {
                    badgeCell.detailTextLabel.text = [NSString stringWithFormat:@"%2.0f%%", percent *100];
                }else{
                    badgeCell.detailTextLabel.text = @"No Data";
                }
                
                badgeCell.detailTextLabel.textColor = [UIColor appTertiaryPurpleColor];
                if (percent > 0.60) {
                    badgeCell.imageView.image = [UIImage imageNamed:@"icon_trophy_purple"];
                }
                if (percent > 0.85){
                    badgeCell.imageView.image = [UIImage imageNamed:@"icon_trophy_purple_crown"];
                }
            }
                break;
            case kAPHBadgesRowTypeUndisturbedNights:
            {
                badgeCell.textLabel.text = NSLocalizedString(@"Undisturbed Nights", @"");
                percent = self.badgeObject.undisturbedNightsValue;
                badgeCell.detailTextLabel.text = [NSString stringWithFormat:@"%2.0f%%", percent *100];
                badgeCell.detailTextLabel.textColor = [UIColor appTertiaryGreenColor];
                if (percent > 0.60) {
                    badgeCell.imageView.image = [UIImage imageNamed:@"icon_trophy_green"];
                }
                if (percent > 0.85){
                    badgeCell.imageView.image = [UIImage imageNamed:@"icon_trophy_green_crown"];
                }
            }
                break;
            case kAPHBadgesRowTypeAsthmaFreeDays:
            {
                badgeCell.textLabel.text = NSLocalizedString(@"Undisturbed Days", @"");
                percent = self.badgeObject.asthmaFreeDaysValue;
                badgeCell.detailTextLabel.text = [NSString stringWithFormat:@"%2.0f%%", percent *100];
                badgeCell.detailTextLabel.textColor = [UIColor appTertiaryYellowColor];
                if (percent > 0.60) {
                    badgeCell.imageView.image = [UIImage imageNamed:@"icon_trophy_yellow"];
                }
                if (percent > 0.85){
                    badgeCell.imageView.image = [UIImage imageNamed:@"icon_trophy_yellow_crown"];
                }
            }
                break;
                
            default:
                break;
        }
        return badgeCell;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        NSIndexPath *itemIndexPath = [NSIndexPath indexPathForRow:(collectionView.tag - kCollectionViewsBaseTag) inSection:0];
        
        APCTableViewDashboardItem *dashboardItem = (APCTableViewDashboardItem *)[self itemForIndexPath:itemIndexPath];
        
        if ([dashboardItem isKindOfClass:[APHTableViewDashboardAQAlertItem class]])
        {
            APHAirQualitySectionHeaderView *headerView = (APHAirQualitySectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kAPHAirQualitySectionHeaderViewIdentifier forIndexPath:indexPath];
            
            if (indexPath.section == 0) {
                headerView.titleLabel.text = @"Today";
            } else {
                headerView.titleLabel.text = @"Tomorrow";
            }
            
            reusableView = headerView;
        }
    }
    
    return reusableView;
}

#pragma mark  UICollectionViewDelegate Methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForRow:(collectionView.tag - kCollectionViewsBaseTag) inSection:0];
    
    APCTableViewDashboardItem *dashboardItem = (APCTableViewDashboardItem *)[self itemForIndexPath:itemIndexPath];
    
    if ([dashboardItem isKindOfClass:[APHTableViewDashboardBadgesItem class]]){
        
        APHCalendarCollectionViewController *calendarView = [[UIStoryboard storyboardWithName:@"APHDashboard" bundle:nil] instantiateViewControllerWithIdentifier:@"APHCalendarCollectionViewController"];
        
        calendarView.dataSource = self.calendarDataModel;
        switch (indexPath.row) {
            case kAPHBadgesRowTypeDailyParticipation:
            {
                calendarView.taskType = kAPHCalendarTaskTypeParticipation;
                [self.navigationController pushViewController:calendarView animated:YES];
            }
                break;
            case kAPHBadgesRowTypeWorkAttendance:
            {
                calendarView.taskType = kAPHCalendarTaskTypeAttendance;
                [self.navigationController pushViewController:calendarView animated:YES];
            }
                break;
            case kAPHBadgesRowTypeUndisturbedNights:
            {
                calendarView.taskType = kAPHCalendarTaskTypeFreeNights;
                [self.navigationController pushViewController:calendarView animated:YES];
            }
                break;
            case kAPHBadgesRowTypeAsthmaFreeDays:
            {
                calendarView.taskType = kAPHCalendarTaskTypeFreeDays;
                [self.navigationController pushViewController:calendarView animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*) __unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.frame), kBadgesCollectionViewCellHeight);
}

#pragma mark - APCConcentricProgressViewDataSource methods

- (NSUInteger)numberOfComponentsInConcentricProgressView
{
    return kNumberOfItemsForBadges;
}

- (CGFloat)concentricProgressView:(APCConcentricProgressView *)__unused concentricProgressView valueForComponentAtIndex:(NSUInteger)index
{
    CGFloat retValue = 0.0;
    switch (index) {
        case kAPHBadgesRowTypeDailyParticipation:
            retValue = self.badgeObject.completionValue;
            break;
        case kAPHBadgesRowTypeWorkAttendance:
            retValue = self.badgeObject.workAttendanceValue;
            break;
        case kAPHBadgesRowTypeUndisturbedNights:
            retValue = self.badgeObject.undisturbedNightsValue;
            break;
        case kAPHBadgesRowTypeAsthmaFreeDays:
            retValue = self.badgeObject.asthmaFreeDaysValue;
            break;
            
        default:
            retValue = 0.0;
            break;
    }
    return retValue;
}

- (UIColor *)concentricProgressView:(APCConcentricProgressView *)__unused concentricProgressView colorForComponentAtIndex:(NSUInteger)index
{
    NSArray *colors = @[[UIColor appTertiaryBlueColor], [UIColor appTertiaryPurpleColor], [UIColor appTertiaryGreenColor], [UIColor appTertiaryYellowColor]];
    
    return colors[index];
}

#pragma mark - APCPieGraphViewDatasource

- (NSInteger)numberOfSegmentsInPieGraphView
{
    return ((self.badgeObject.asthmaFullyControlUserScore == 0) && (self.badgeObject.asthmaFullyControlUserScore == 0)) ? 1 : 2;
}

- (CGFloat)pieGraphView:(APCPieGraphView *)__unused pieGraphView valueForSegmentAtIndex:(NSInteger)index
{
    CGFloat retValue = 0;
    if ( ((self.badgeObject.asthmaFullyControlUserScore == 0) && (self.badgeObject.asthmaFullyControlUserScore == 0)) ) {
        if (index == 0) {
            retValue = 100;
        }
    }
    else
    {
        if (index == 0)
        {
            retValue = self.badgeObject.asthmaFullyControlUserScore;
        }
        else if (index == 1)
        {
            retValue = (self.badgeObject.asthmaFullyControlTotalScore - self.badgeObject.asthmaFullyControlUserScore);
        }
    }
    return retValue;
}

- (NSString *)pieGraphView:(APCPieGraphView *)__unused pieGraphView titleForSegmentAtIndex:(NSInteger)index
{
    NSArray *titles = @[@"Well Controlled", @"Could Be Better"];
    return ((self.badgeObject.asthmaFullyControlUserScore == 0) && (self.badgeObject.asthmaFullyControlUserScore == 0)) ? @"Not Available Yet" : titles[index];
}

- (UIColor *)pieGraphView:(APCPieGraphView *)__unused pieGraphView colorForSegmentAtIndex:(NSInteger)index
{
    NSArray *colors = @[[UIColor appTertiaryGreenColor], [UIColor appTertiaryRedColor]];
    
    return ((self.badgeObject.asthmaFullyControlUserScore == 0) && (self.badgeObject.asthmaFullyControlUserScore == 0))?[UIColor appTertiaryYellowColor] :colors[index];
}

/*********************************************************************************/
#pragma mark - Overriding APHDashboardVC
/*********************************************************************************/
- (void)updateVisibleRowsInTableView:(NSNotification *)notification
{
    [super updateVisibleRowsInTableView:notification];
    [self prepareData];
    self.shouldAnimateObjects = YES;
}

#pragma mark - APHAirQualityDataModel
-(void)airQualityModel:(APHAirQualityDataModel *)__unused model didDeliverAirQualityAlert:(APHTableViewDashboardAQAlertItem *)alert{
    
    self.aqiObject = alert;
    self.numberOfItemsForAirQuality = 4;
    self.airQualityCollectionViewCellHeight = 54.0f;
    self.airQualityCollectionViewHeaderHeight = 36.0f;
    self.aqiObject.showTomorrowInfo = YES;
    self.shouldAnimateObjects = NO;
    [self prepareData];
    self.shouldAnimateObjects = YES;
    
}

@end
