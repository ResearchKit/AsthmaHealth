// 
//  APHCalendarCollectionViewController.m 
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
 
#import "APHCalendarCollectionViewController.h"
#import "APHCalendarCollectionViewCell.h"

@import APCAppCore;
@interface APHCalendarCollectionViewController ()

//navigation
@property (strong, nonatomic) UIButton *nextMonthButton;
@property (strong, nonatomic) UIButton *lastMonthButton;

//calendrical calculation
@property (assign, nonatomic) NSInteger MM;
@property (assign, nonatomic) NSInteger YYYY;
@property (strong, nonatomic) NSString *MMYYYYString;
@property (strong, nonatomic) NSArray *currentMonthDays;

//compliance
@property (strong, nonatomic) NSDictionary *compliance;

//design attributes
@property (strong, nonatomic) UIColor *weekdayFontColor;
@property (strong, nonatomic) UIColor *weekendFontColor;
@property (strong, nonatomic) UIColor *complianceBarColor;
@property (strong, nonatomic) UIColor *nonComplianceBarColor;
@property (strong, nonatomic) UIColor *unscheduledBarColor;

@end

@implementation APHCalendarCollectionViewController

static NSString * const reuseIdentifier = @"calendarCell";
static CGFloat calendarCellHeight = 44.0;
static CGFloat calendarMonthFontSize = 16.0;
static CGFloat calendarDayLabelFontSize = 16.0;
static CGFloat calendarDateFontSize = 16.0;
static int divisorForCollectionViewCellWidth = 8;
static int numberOfSectionsInCollectionView = 7;
static int numberOfItemsInSection = 7;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.taskType == kAPHCalendarTaskTypeParticipation) {
        self.title = NSLocalizedString (@"Survey Completion", nil);
    }
    if (self.taskType == kAPHCalendarTaskTypeAttendance) {
        self.title = NSLocalizedString(@"Work Attendance", nil);
    }
    if (self.taskType == kAPHCalendarTaskTypeFreeDays) {
        self.title = NSLocalizedString(@"Undisturbed Days", nil);
    }
    if (self.taskType == kAPHCalendarTaskTypeFreeNights) {
        self.title = NSLocalizedString(@"Undisturbed Nights", nil);
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView:) name:calendarDataSourceDidUpdateComplianceDictionaryNotification object:nil];
    //posted by APCBaseTaskViewController when user completes an activity
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataUpdate) name:APCActivityCompletionNotification object:nil];

    [self setCalendarAttributes];
    [self setDesignAttributes];
    [self setNavigationAttributes];
    
    [self.nextMonthButton setTransform: CGAffineTransformMakeRotation(M_PI)];
    // Register cell classes
    [self.collectionView registerClass:[APHCalendarCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) reloadCollectionView: (NSNotification *)notification
{
    [self performSelector:@selector(dismiss) withObject:self afterDelay:0.5];
    self.compliance = (NSDictionary *)[notification object];
    [self.collectionView reloadData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setCalendarAttributes
{
    self.MM = [self MMForCurrentMonth];
    self.YYYY = [self YYYYForCurrentMonth];
    [self setMMYYYY];
    [self setCurrentMonthDays];
    [self getDataUpdate];
}

-(void)setDesignAttributes
{
    
    self.weekdayFontColor = [UIColor darkGrayColor];
    self.weekendFontColor = [UIColor lightGrayColor];
    self.complianceBarColor = [UIColor greenColor];
    self.nonComplianceBarColor = [UIColor redColor];
    self.unscheduledBarColor = [UIColor clearColor];
    
}

-(void)setNavigationAttributes
{
    //setup buttons
    self.nextMonthButton = [[UIButton alloc]init];
    
    [self.nextMonthButton setBackgroundImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [self.nextMonthButton addTarget:self action:@selector(nextMonthAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.lastMonthButton = [[UIButton alloc]init];
    [self.lastMonthButton setBackgroundImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [self.lastMonthButton addTarget:self action:@selector(lastMonthAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem  *backButton = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backButton];
}

- (void)getDataUpdate{
    //ask the delegate for the compliance
    
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    [self.dataSource createComplianceDictionaryForTaskType:self.taskType inMonth:self.MM inYear:self.YYYY];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView
{
    return numberOfSectionsInCollectionView;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger) __unused section
{
    return numberOfItemsInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    APHCalendarCollectionViewCell *calendarCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    calendarCell.contentView.backgroundColor = [UIColor whiteColor];
    
    switch (indexPath.section) {
        case 0:
            calendarCell.contentView.backgroundColor = [UIColor whiteColor];
            switch (indexPath.item) {
                    //Weekday Labels
                case 0:
                    [calendarCell setDateText:@"S" complianceColor:[UIColor clearColor] fontSize:calendarDayLabelFontSize fontColor:self.weekendFontColor];
                    break;
                case 1:
                    [calendarCell setDateText:@"M" complianceColor:[UIColor clearColor] fontSize:calendarDayLabelFontSize fontColor:self.weekdayFontColor];
                    break;
                case 2:
                    [calendarCell setDateText:@"T" complianceColor:[UIColor clearColor] fontSize:calendarDayLabelFontSize fontColor:self.weekdayFontColor];
                    break;
                case 3:
                    [calendarCell setDateText:@"W" complianceColor:[UIColor clearColor] fontSize:calendarDayLabelFontSize fontColor:self.weekdayFontColor];
                    break;
                case 4:
                    [calendarCell setDateText:@"T" complianceColor:[UIColor clearColor] fontSize:calendarDayLabelFontSize fontColor:self.weekdayFontColor];
                    break;
                case 5:
                    [calendarCell setDateText:@"F" complianceColor:[UIColor clearColor] fontSize:calendarDayLabelFontSize fontColor:self.weekdayFontColor];
                    break;
                case 6:
                    [calendarCell setDateText:@"S" complianceColor:[UIColor clearColor] fontSize:calendarDayLabelFontSize fontColor:self.weekendFontColor];
                    break;
                default:
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.item) {
                case 0:
                    [calendarCell setDateText:_currentMonthDays[0] complianceColor:[self complianceColorForDay:_currentMonthDays[0]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                    break;
                case 1:
                    [calendarCell setDateText:_currentMonthDays[1] complianceColor:[self complianceColorForDay:_currentMonthDays[1]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 2:
                    [calendarCell setDateText:_currentMonthDays[2] complianceColor:[self complianceColorForDay:_currentMonthDays[2]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 3:
                    [calendarCell setDateText:_currentMonthDays[3] complianceColor:[self complianceColorForDay:_currentMonthDays[3]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 4:
                    [calendarCell setDateText:_currentMonthDays[4] complianceColor:[self complianceColorForDay:_currentMonthDays[4]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 5:
                    [calendarCell setDateText:_currentMonthDays[5] complianceColor:[self complianceColorForDay:_currentMonthDays[5]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 6:
                    [calendarCell setDateText:_currentMonthDays[6] complianceColor:[self complianceColorForDay:_currentMonthDays[6]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.item) {
                case 0:
                    [calendarCell setDateText:_currentMonthDays[7] complianceColor:[self complianceColorForDay:_currentMonthDays[7]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                    break;
                case 1:
                    [calendarCell setDateText:_currentMonthDays[8] complianceColor:[self complianceColorForDay:_currentMonthDays[8]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 2:
                    [calendarCell setDateText:_currentMonthDays[9] complianceColor:[self complianceColorForDay:_currentMonthDays[9]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 3:
                    [calendarCell setDateText:_currentMonthDays[10] complianceColor:[self complianceColorForDay:_currentMonthDays[10]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 4:
                    [calendarCell setDateText:_currentMonthDays[11] complianceColor:[self complianceColorForDay:_currentMonthDays[11]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 5:
                    [calendarCell setDateText:_currentMonthDays[12] complianceColor:[self complianceColorForDay:_currentMonthDays[12]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 6:
                    [calendarCell setDateText:_currentMonthDays[13] complianceColor:[self complianceColorForDay:_currentMonthDays[13]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.item) {
                case 0:
                    [calendarCell setDateText:_currentMonthDays[14] complianceColor:[self complianceColorForDay:_currentMonthDays[14]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                    break;
                case 1:
                    [calendarCell setDateText:_currentMonthDays[15] complianceColor:[self complianceColorForDay:_currentMonthDays[15]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 2:
                    [calendarCell setDateText:_currentMonthDays[16] complianceColor:[self complianceColorForDay:_currentMonthDays[16]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 3:
                    [calendarCell setDateText:_currentMonthDays[17] complianceColor:[self complianceColorForDay:_currentMonthDays[17]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 4:
                    [calendarCell setDateText:_currentMonthDays[18] complianceColor:[self complianceColorForDay:_currentMonthDays[18]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 5:
                    [calendarCell setDateText:_currentMonthDays[19] complianceColor:[self complianceColorForDay:_currentMonthDays[19]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 6:
                    [calendarCell setDateText:_currentMonthDays[20] complianceColor:[self complianceColorForDay:_currentMonthDays[20]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                default:
                    break;
            }
            break;
        case 4:
            switch (indexPath.item) {
                case 0:
                    [calendarCell setDateText:_currentMonthDays[21] complianceColor:[self complianceColorForDay:_currentMonthDays[21]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                    break;
                case 1:
                    [calendarCell setDateText:_currentMonthDays[22] complianceColor:[self complianceColorForDay:_currentMonthDays[22]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 2:
                    [calendarCell setDateText:_currentMonthDays[23] complianceColor:[self complianceColorForDay:_currentMonthDays[23]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 3:
                    [calendarCell setDateText:_currentMonthDays[24] complianceColor:[self complianceColorForDay:_currentMonthDays[24]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 4:
                    [calendarCell setDateText:_currentMonthDays[25] complianceColor:[self complianceColorForDay:_currentMonthDays[25]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 5:
                    [calendarCell setDateText:_currentMonthDays[26] complianceColor:[self complianceColorForDay:_currentMonthDays[26]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 6:
                    [calendarCell setDateText:_currentMonthDays[27] complianceColor:[self complianceColorForDay:_currentMonthDays[27]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                default:
                    break;
            }
            break;
        case 5:
            switch (indexPath.item) {
                case 0:
                    [calendarCell setDateText:_currentMonthDays[28] complianceColor:[self complianceColorForDay:_currentMonthDays[28]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                    break;
                case 1:
                    [calendarCell setDateText:_currentMonthDays[29] complianceColor:[self complianceColorForDay:_currentMonthDays[29]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 2:
                    [calendarCell setDateText:_currentMonthDays[30] complianceColor:[self complianceColorForDay:_currentMonthDays[30]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 3:
                    [calendarCell setDateText:_currentMonthDays[31] complianceColor:[self complianceColorForDay:_currentMonthDays[31]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 4:
                    [calendarCell setDateText:_currentMonthDays[32] complianceColor:[self complianceColorForDay:_currentMonthDays[32]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 5:
                    [calendarCell setDateText:_currentMonthDays[33] complianceColor:[self complianceColorForDay:_currentMonthDays[33]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 6:
                    [calendarCell setDateText:_currentMonthDays[34] complianceColor:[self complianceColorForDay:_currentMonthDays[34]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                default:
                    break;;
            }
            break;
            
        case 6:
            switch (indexPath.item) {
                case 0:
                    [calendarCell setDateText:_currentMonthDays[35] complianceColor:[self complianceColorForDay:_currentMonthDays[35]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                    break;
                case 1:
                    [calendarCell setDateText:_currentMonthDays[36] complianceColor:[self complianceColorForDay:_currentMonthDays[36]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 2:
                    [calendarCell setDateText:_currentMonthDays[37] complianceColor:[self complianceColorForDay:_currentMonthDays[37]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 3:
                    [calendarCell setDateText:_currentMonthDays[38] complianceColor:[self complianceColorForDay:_currentMonthDays[38]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 4:
                    [calendarCell setDateText:_currentMonthDays[39] complianceColor:[self complianceColorForDay:_currentMonthDays[39]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 5:
                    [calendarCell setDateText:_currentMonthDays[40] complianceColor:[self complianceColorForDay:_currentMonthDays[40]] fontSize:calendarDateFontSize fontColor:self.weekdayFontColor];
                    break;
                case 6:
                    [calendarCell setDateText:_currentMonthDays[41] complianceColor:[self complianceColorForDay:_currentMonthDays[41]] fontSize:calendarDateFontSize fontColor:self.weekendFontColor];
                default:
                    break;;
            }
            break;
            
        default:
            
            break;
    }
    
    return calendarCell;
}

-(UIColor *)complianceColorForDay: (NSString *)day{
    UIColor *complianceColor;
    if ([[self.compliance objectForKey:day] isEqualToString:@""] || ![self.compliance objectForKey:day]) {
        complianceColor = [UIColor clearColor];
    }
    if ([[self.compliance objectForKey:day] isEqualToString:@"1"]) {
        complianceColor = self.complianceBarColor;
    }
    if ([[self.compliance objectForKey:day] isEqualToString:@"0"]) {
        complianceColor = self.nonComplianceBarColor;
    }
    
    return complianceColor;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)__unused collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableView;
    if ([kind isEqualToString:@"UICollectionElementKindSectionHeader"]) {
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor whiteColor];
        
        for (UIView *view in reusableView.subviews) {
            [view removeFromSuperview];
        }
        
        if (indexPath.section == 0) {
            //Month Toolbar
            UILabel *monthLabel = [[UILabel alloc]initWithFrame:reusableView.frame];
            monthLabel.text = self.MMYYYYString;
            monthLabel.font = [UIFont appRegularFontWithSize:calendarMonthFontSize];
            monthLabel.textColor = [UIColor blackColor];
            [monthLabel setTextAlignment:NSTextAlignmentCenter];
            [reusableView addSubview:monthLabel];
            
            CGRect lastMonthButtonFrame = CGRectMake(10, 0, 45, 45);
            [self.lastMonthButton setFrame:lastMonthButtonFrame];
            [reusableView addSubview:self.lastMonthButton];
            
            CGRect nextMonthButtonFrame = CGRectMake(self.view.frame.size.width - 55, 0, 45, 45);
            [self.nextMonthButton setFrame:nextMonthButtonFrame];
            [reusableView addSubview:self.nextMonthButton];
            
        }
        
        
    }else if ([kind isEqualToString:@"UICollectionElementKindSectionFooter"]){
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sectionFooter" forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor lightGrayColor];
    }
    
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout*)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath{
    
    return CGSizeMake(self.collectionView.frame.size.width / divisorForCollectionViewCellWidth, calendarCellHeight);
    
}

#pragma mark Navigation
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark calendrical calculation
-(void)nextMonthAction: (id)__unused sender{
    //increment MM
    self.MM++;
    if (self.MM == 13) {
        //if MM == 13, MM = 01
        self.MM = 1;
        //increment YYYY if MM == 13
        self.YYYY++;
    }
    [self setMMYYYY];
    [self setCurrentMonthDays];
    [self getDataUpdate];
}

-(void)lastMonthAction: (id)__unused sender{
    //decrement MM
    self.MM--;
    if (self.MM == 0) {
        //if MM == 0, MM = 12
        self.MM = 12;
        //decrement YYYY if MM = 01
        self.YYYY--;
    }
    [self setMMYYYY];
    [self setCurrentMonthDays];
    [self getDataUpdate];
}

-(void)setCurrentMonthDays{
    
    //get the first day of the current month
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:self.MM];
    [comps setYear:self.YYYY];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:comps];
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:date];
    
    NSInteger weekday = [weekdayComponents weekday];//Sunday == 1
    
    NSMutableArray *dayStrings = [[NSMutableArray alloc]init];
    
    NSInteger i = 1;
    while (weekday != i) {
        [dayStrings addObject:@""];
        i++;
    }
    
    NSInteger j = 1;
    //render 6 weeks of calendar to page, with days as appropriate
    while (i < 43) {
        if ([self isValidDateForDay:j month:self.MM year:self.YYYY]) {
            [dayStrings addObject:[NSString stringWithFormat:@"%i", (int)j]];
        }else{
            [dayStrings addObject:[NSString stringWithFormat:@""]];
        }
        j++; i++;
    }
    
    self.currentMonthDays = dayStrings;
    
}

-(BOOL)isValidDateForDay:(NSInteger)DD month:(NSInteger)MM year:(NSInteger)YYYY{
    
    //Check validity of date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
    
    NSString *endDateString = [NSString stringWithFormat:@"%i-%i-%i", (int)YYYY, (int)MM, (int)DD];
    NSDate *endDate = [dateFormatter dateFromString:endDateString];
    
    return endDate != nil;
    
}

-(NSInteger)MMForCurrentMonth{
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitMonth) fromDate:today];
    NSInteger month = [weekdayComponents month];
    return month;
}

-(NSInteger)YYYYForCurrentMonth{
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitYear) fromDate:today];
    NSInteger year = [weekdayComponents year];
    return year;
}

-(void)setMMYYYY{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:self.MM];
    [comps setYear:self.YYYY];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *date = [gregorian dateFromComponents:comps];
    NSDateComponents *monthComponents = [gregorian components:(NSCalendarUnitMonth) fromDate:date];
    NSInteger month = [monthComponents month];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSArray *monthSymbols = [dateFormatter monthSymbols];
    self.MMYYYYString = [NSString stringWithFormat:@"%@ %i",[monthSymbols objectAtIndex:month -1], (int)self.YYYY];
}


@end
