// 
//  APHInclusionCriteriaViewController.m 
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
 


#import "APHInclusionCriteriaViewController.h"
#import "APHSignUpGeneralInfoViewController.h"

static NSInteger kDatePickerCellRow = 3;

@interface APHInclusionCriteriaViewController () <APCSegmentedButtonDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet UILabel *question1Label;
@property (weak, nonatomic) IBOutlet UILabel *question2Label;
@property (weak, nonatomic) IBOutlet UILabel *question3Label;
@property (weak, nonatomic) IBOutlet UILabel *question4Label;

@property (weak, nonatomic) IBOutlet UIButton *question1Option1;
@property (weak, nonatomic) IBOutlet UIButton *question1Option2;

@property (weak, nonatomic) IBOutlet UIButton *question2Option1;
@property (weak, nonatomic) IBOutlet UIButton *question2Option2;
@property (weak, nonatomic) IBOutlet UIButton *question2Option3;

@property (weak, nonatomic) IBOutlet UIButton *question4Option1;
@property (weak, nonatomic) IBOutlet UIButton *question4Option2;
@property (weak, nonatomic) IBOutlet UIButton *question4Option3;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateTitleCell;

//Properties
@property (nonatomic, strong) NSArray * questions; //Of APCSegmentedButtons

@property (nonatomic, strong) NSDate* diagnosisDate;
@property (nonatomic, getter = isDateOpen) BOOL dateOpen;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation APHInclusionCriteriaViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    self.questions = @[
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question1Option1, self.question1Option2] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]],
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question2Option1, self.question2Option2, self.question2Option3] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]],
                       [[APCSegmentedButton alloc] initWithButtons:@[self.question4Option1, self.question4Option2, self.question4Option3] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appPrimaryColor]]
                       ];
    [self.questions enumerateObjectsUsingBlock:^(APCSegmentedButton * obj, NSUInteger idx, BOOL *stop) {
        obj.delegate = self;
    }];
    [self setUpAppearance];
}

- (void) setUpAppearance
{
    self.question1Label.textColor = [UIColor appSecondaryColor1];
    self.question2Label.textColor = [UIColor appSecondaryColor1];
    self.question3Label.textColor = [UIColor appSecondaryColor1];
    self.question4Label.textColor = [UIColor appSecondaryColor1];

    self.dateLabel.textColor = [UIColor appSecondaryColor3];
    self.dateLabel.font = [UIFont appRegularFontWithSize:16];
    self.dateLabel.text = NSLocalizedString(@"Enter Date", "");

    self.question2Option3.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.question2Option3.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.question2Option3 setTitle:NSLocalizedString(@"Not\nSure", @"Question Option") forState:UIControlStateNormal];
}

- (void)startSignUp
{
    APHSignUpGeneralInfoViewController *signUpVC = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpGeneralInfoVC"];
    [self.navigationController pushViewController:signUpVC animated:YES];

}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == kDatePickerCellRow && !self.isDateOpen){
        return 0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView beginUpdates];
    if (cell == self.dateTitleCell) {
        self.dateOpen = !self.isDateOpen;
        if (self.dateOpen) {
            if (self.diagnosisDate) {
                self.datePicker.date = self.diagnosisDate;
            }
            else
            {
                self.diagnosisDate = self.datePicker.date;
                self.dateLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
            }
        }
    }
    [self.tableView endUpdates];
    if (cell == self.dateTitleCell) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (IBAction)datePickerChanged:(UIDatePicker*)sender
{
    self.diagnosisDate = sender.date;
    self.dateLabel.text = [self.dateFormatter stringFromDate:sender.date];
}


/*********************************************************************************/
#pragma mark - Misc Fix
/*********************************************************************************/
-(void)viewDidLayoutSubviews
{
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

/*********************************************************************************/
#pragma mark - Segmented Button Delegate
/*********************************************************************************/
- (void)segmentedButtonPressed:(UIButton *)button selectedIndex:(NSInteger)selectedIndex
{
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid];
}

/*********************************************************************************/
#pragma mark - Overridden methods
/*********************************************************************************/

- (void)next
{
    //TODO: Remove comments in Dev branch
    //#ifdef DEVELOPMENT
    //        APHSignUpGeneralInfoViewController *signUpVC = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpGeneralInfoVC"];
    //        [self.navigationController pushViewController:signUpVC animated:YES];
    //#else
    if ([self isEligible]) {

        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"EligibleVC"] animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"InEligibleVC"] animated:YES];
    }
    //#endif
}

- (BOOL) isEligible
{
    BOOL retValue = YES;
    APCSegmentedButton * question2Button = self.questions[1];
    if (question2Button.selectedIndex == 1) {
        retValue = NO;
    }
    return retValue;
}

- (BOOL)isContentValid
{
#ifdef DEVELOPMENT
    return YES;
#else
    __block BOOL retValue = YES;
    [self.questions enumerateObjectsUsingBlock:^(APCSegmentedButton* obj, NSUInteger idx, BOOL *stop) {
        if (obj.selectedIndex == -1) {
            retValue = NO;
            *stop = YES;
        }
    }];
    if (!self.diagnosisDate) {
        retValue = NO;
    }

    return retValue;
#endif
}

@end
