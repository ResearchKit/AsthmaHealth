// 
//  APHEnrollmentIntroTableViewController.m 
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
 
#import "APHEnrollmentIntroTableViewController.h"
#import "APHEnrollmentIntroduction.h"

static  NSInteger  kDescriptionCell = 0;
static  NSInteger  kFirstSegmentationCell = 1;
static  NSInteger  kSelectYesCell = 2;
static  NSInteger  kPreferredSegmentationCell = 3;
static  NSInteger  kEmailCell = 4;
static  NSInteger  kPhoneNumberCell = 5;
static  NSInteger  kPatientCell = 6;
static  NSInteger  kSecondSegmentationCell = 7;
static  NSInteger  kSelectNoCell = 8;

static  NSInteger  kNormalCellHeight = 44;
static  NSInteger  kHasTextCellHeight = 90;
static  NSInteger  kZeroCellHeight = 0;
static  NSInteger  kInstructionsCellHeight = 200;
static  NSInteger  kFirstSegmentationCellHeight = 12;

static  NSInteger  kTotalLengthOfPhoneNumber = 10;
static  NSInteger  kLengthOfAreaCode = 3;
static  NSInteger  kLengthBeforePhoneFormatWithDash = 6;

static NSInteger kTotalNumberOfRows = 9;
static NSInteger kTotalNumberOfSections = 1;

@interface APHEnrollmentIntroTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *cell0;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell3;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell4;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell5;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell6;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell7;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell8;

@property (weak, nonatomic) IBOutlet APCConfirmationView *yesSelectedView;
@property (weak, nonatomic) IBOutlet APCConfirmationView *noSelectedView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) APHEnrollmentIntroduction *parent;

@property (weak, nonatomic) IBOutlet UILabel*    isPatientLabel;

@end

@implementation APHEnrollmentIntroTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.phoneTextInput setDelegate:self];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(handleTapFrom:)];
}

- (void) handleTapFrom: (UITapGestureRecognizer *)__unused recognizer
{
    [self.phoneTextInput resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.cell0.textLabel.numberOfLines = 0;
    self.cell0.textLabel.text = NSLocalizedString(@"Congratulations, you are now registered for the study. If you would like to help us build an even better app, we would also appreciate it if we could contact you to discuss your personal experience in more detail.", @"");;
    
    self.cell0.textLabel.textColor = [UIColor appSecondaryColor1];
    
    self.cell0.textLabel.font = [UIFont systemFontOfSize:19.0f];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.emailTextInput.userInteractionEnabled = NO;
    
    self.emailTextInput.text = (NSString *)[((APCAppDelegate*)[UIApplication sharedApplication].delegate) dataSubstrate].currentUser.email;
    
    [self.cell4 setHidden:YES];
    [self.cell5 setHidden:YES];
    [self.cell6 setHidden:YES];
    [self.cell7 setHidden:YES];
    
    self.isPatientInput.on   = NO;
    self.isPatientLabel.text = NSLocalizedString(@"Currently NOT a Mount Sinai patient", nil);
    
    self.parent = (APHEnrollmentIntroduction *) self.parentViewController;
    [self.parent.submitButton setEnabled:NO];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)__unused textField {
    [self.view addGestureRecognizer:self.tapGestureRecognizer];

    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];

    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    
    UIBarButtonItem* flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(doneClicked:)];
    
    UIBarButtonItem* flexButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(doneClicked:)];
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexButton, flexButton2, doneButton, nil]];
    self.phoneTextInput.inputAccessoryView = keyboardDoneButtonView;
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)__unused string{
    
    int length = [self getLength:textField.text];
    
    if(length == kTotalLengthOfPhoneNumber)
    {
        if(range.length == 0)
            return NO;
    }
    
    if(length == kLengthOfAreaCode)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) ",num];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    }
    else if(length == kLengthBeforePhoneFormatWithDash)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (unsigned int)[mobileNumber length];

    if(length > kTotalLengthOfPhoneNumber)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (unsigned int)[mobileNumber length];
    
    return length;
}

- (IBAction)isPatientToggled:(id) __unused sender
{
    if (self.isPatientInput.on)
    {
        [UIView transitionWithView:self.isPatientLabel
                          duration:.40f
                           options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.isPatientLabel.text = NSLocalizedString(@"Currently a Mount Sinai patient", nil);
                        }
                        completion:nil];
    }
    else
    {
        [UIView transitionWithView:self.isPatientLabel
                          duration:.40f
                           options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.isPatientLabel.text = NSLocalizedString(@"Currently NOT a Mount Sinai patient", nil);
                        }
                        completion:nil];
    }
}


- (IBAction)doneClicked:(id)__unused sender
{
    [self.view endEditing:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)__unused textField {
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
}

- (void)doneButtonClicked:(id)__unused sender {
    [self.phoneTextInput resignFirstResponder];
}

- (CGFloat) tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = kNormalCellHeight;

    if (self.yesCellSelected) {
        
        if (indexPath.row == kEmailCell || indexPath.row == kPhoneNumberCell) {
            height = kHasTextCellHeight;
        }
        
        if (indexPath.row == kPreferredSegmentationCell || indexPath.row == kSecondSegmentationCell) {
            height = kNormalCellHeight;
        }
    } else {
        
        if (indexPath.row == kPreferredSegmentationCell || indexPath.row == kEmailCell ||
            indexPath.row == kPhoneNumberCell || indexPath.row == kPatientCell || indexPath.row == kSecondSegmentationCell)
        {
            height = kZeroCellHeight;
        }
    }
    
    if (indexPath.row == kDescriptionCell) {
        height = kInstructionsCellHeight;
    }
    
    if (indexPath.row == kSelectYesCell ||  indexPath.row == kSelectNoCell) {
        height = kHasTextCellHeight;
    }
    
    if (indexPath.row == kFirstSegmentationCell) {
        height = kFirstSegmentationCellHeight;
    }
    
    return height;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {

    return kTotalNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {

    return kTotalNumberOfRows;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kSelectYesCell) {
        if (self.yesCellSelected) {
            [self setTableViewOnSelectedNoCell];
            [self.noSelectedView setCompleted:NO];
            
            [self.parent.submitButton setEnabled:NO];
            
            
        } else {
            [self setTableViewOnSelectedYesCell];
            
            [self.parent.submitButton setEnabled:YES];
        }
    } else if (indexPath.row == kSelectNoCell) {
        [self setTableViewOnSelectedNoCell];
    }
    else if (indexPath.row == kPatientCell)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)setTableViewOnSelectedYesCell {
    
    [self.cell4 setHidden:NO];
    [self.cell5 setHidden:NO];
    [self.cell6 setHidden:NO];
    [self.cell7 setHidden:NO];
    
    self.yesCellSelected = YES;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.yesSelectedView setCompleted:YES];
        [self.noSelectedView setCompleted:NO];
    }];
}

- (void)setTableViewOnSelectedNoCell {
    
    [self.cell4 setHidden:YES];
    [self.cell5 setHidden:YES];
    [self.cell6 setHidden:YES];
    [self.cell7 setHidden:YES];
    
    self.yesCellSelected = NO;
    
    [self.parent.submitButton setEnabled:YES];
    
    if (!self.yesSelectedView.completed && self.noSelectedView.completed) {
        [UIView animateWithDuration:0.4 animations:^{
            [self.yesSelectedView setCompleted:NO];
            [self.noSelectedView setCompleted:NO];
            [self.parent.submitButton setEnabled:NO];
        }];
    } else if (self.yesSelectedView.completed) {
        [UIView animateWithDuration:0.4 animations:^{
            [self.yesSelectedView setCompleted:NO];
            [self.noSelectedView setCompleted:YES];
            
            [self.parent.submitButton setEnabled:YES];
        }];
    } else if (!self.yesSelectedView.completed && !self.noSelectedView.completed) {
        [UIView animateWithDuration:0.4 animations:^{
            [self.yesSelectedView setCompleted:NO];
            [self.noSelectedView setCompleted:YES];
            
            [self.parent.submitButton setEnabled:YES];
        }];
    }
}

@end
