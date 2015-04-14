// 
//  APHStudyOverviewViewController.m 
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
#import "APHStudyOverviewViewController.h"
#import "APHSignInViewController.h"
#import "APHSignUpGeneralInfoViewController.h"
#import "APHInclusionCriteriaViewController.h"


static NSString * const kStudyOverviewCellIdentifier = @"kStudyOverviewCellIdentifier";

@interface APHStudyOverviewViewController ()

@property (nonatomic, strong) NSArray *studyDetailsArray;
@property (nonatomic, strong) NSArray * imagesArray;
@property (nonatomic, strong) NSArray * colorsArray;

@end

@implementation APHStudyOverviewViewController

- (void)prepareContent
{
    _studyDetailsArray = [self studyDetailsFromJSONFile:@"StudyOverview"];
}

- (NSArray *)imagesArray
{
    return @[
             @"paperplus_icon",
             @"rulerpencil_icon",
             @"stethescope_icon",
             @"clipboard_icon",
             @"stopwatch_icon"
             ];
}

- (NSArray *)colorsArray
{
    return @[
             [UIColor colorWithRed:0.132 green:0.684 blue:0.959 alpha:1.000],
             [UIColor colorWithRed:0.919 green:0.226 blue:0.342 alpha:1.000],
             [UIColor colorWithRed:0.195 green:0.830 blue:0.443 alpha:1.000],
             [UIColor colorWithRed:0.994 green:0.709 blue:0.278 alpha:1.000],
             [UIColor colorWithRed:0.574 green:0.252 blue:0.829 alpha:1.000]
             ];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self prepareContent];
    self.logoImageView.image = [UIImage imageNamed:@"logo_research_institute"];
    [self setUpAppearance];
    [self setupTable];
}

- (void)setUpAppearance
{
    //Headerview
    self.headerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.headerView.layer.shadowOffset = CGSizeMake(0, 1);
    self.headerView.layer.shadowOpacity = 0.6;
    self.headerView.layer.shadowRadius = 0.5;

    [self.joinButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    [self.joinButton setTitleColor:[UIColor appSecondaryColor4] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor appSecondaryColor2]] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor appSecondaryColor4] forState:UIControlStateNormal];

    self.diseaseNameLabel.font = [UIFont appMediumFontWithSize:19];
    self.diseaseNameLabel.textColor = [UIColor appSecondaryColor1];
    self.dateRangeLabel.font = [UIFont appLightFontWithSize:16];
    self.dateRangeLabel.textColor = [UIColor appSecondaryColor3];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTable
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.studyDetailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStudyOverviewCellIdentifier forIndexPath:indexPath];

    APCStudyDetails *studyDetails = self.studyDetailsArray[indexPath.row];

    UIView * view = [cell viewWithTag:100];
    view.backgroundColor = self.colorsArray[indexPath.row];

    UIImageView * imageView = (UIImageView*) [cell viewWithTag:200];
    imageView.image = [UIImage imageNamed:self.imagesArray[indexPath.row]];

    UILabel * label = (UILabel*) [cell viewWithTag:300];
    label.text = studyDetails.title;

    [self setUpCellAppearance:cell];
    return cell;
}

- (void) setUpCellAppearance: (UITableViewCell*) cell
{
    UILabel * label = (UILabel*) [cell viewWithTag:300];
    label.font = [UIFont appRegularFontWithSize:16];
    label.textColor = [UIColor appSecondaryColor1];
}

#pragma mark - IBActions

- (void)signInTapped:(id)sender
{
    APCForgotPasswordViewController *signInViewController = [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"SignInVC"];
    [self.navigationController pushViewController:signInViewController animated:YES];
}

- (void)signUpTapped:(id)sender
{
    [self.navigationController pushViewController: [[UIStoryboard storyboardWithName:@"APHOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"InclusionCriteriaVC"] animated:YES];
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

@end
