// 
//  APHEnrollmentIntroduction.m 
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
 
#import "APHEnrollmentIntroduction.h"
#import "APHEnrollmentIntroTableViewController.h"


@interface SBBUserProfile (customFields)

//  IMPORTANT NOTE:
//
//  These custom fields are how the BridgeSDK supports app-specific user properties.
//
//  The naming convention of these properties *must not* change. These names are converted to string
//  by the BridgeSDK and must match the equavalent item on the server in order to be stored.
@property (nonatomic, strong) NSString* can_be_recontacted;
@property (nonatomic, strong) NSString* recontact_number;
@property (nonatomic, strong) NSString* recontact_email;
@property (nonatomic, strong) NSString* mtsinai_patient;

@end

@implementation SBBUserProfile (customFields)

@dynamic can_be_recontacted;
@dynamic recontact_number;
@dynamic recontact_email;
@dynamic mtsinai_patient;

@end


@interface APHEnrollmentIntroduction ()

- (IBAction)submitButtonHandler:(id)sender;
@property (nonatomic, strong) ORKStepResult *cachedResult;
@property (nonatomic, strong) APHEnrollmentIntroTableViewController *enrollmentIntroTableViewController;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation APHEnrollmentIntroduction

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view layoutIfNeeded];

}

- (ORKStepResult *)result {
    
    if (!self.cachedResult) {
        self.cachedResult = [[ORKStepResult alloc] initWithIdentifier:self.step.identifier];
    }
    
    return self.cachedResult;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)__unused sender {
    
    if ([segue.identifier isEqualToString: @"APHEnrollmentIntroTableViewControllerSegue"]) {
        self.enrollmentIntroTableViewController = (APHEnrollmentIntroTableViewController *) [segue destinationViewController];
        [self addChildViewController:self.enrollmentIntroTableViewController];
    }
}

- (IBAction)submitButtonHandler:(id)__unused sender {
    APCUser*    theUser = [((APCAppDelegate*)[UIApplication sharedApplication].delegate) dataSubstrate].currentUser;
    
    if (self.enrollmentIntroTableViewController.yesCellSelected) {
        BOOL        recontactAllowed = self.enrollmentIntroTableViewController.yesCellSelected;
        NSString*   recontactNumber  = self.enrollmentIntroTableViewController.phoneTextInput.text;
        NSString*   recontactEmail   = self.enrollmentIntroTableViewController.emailTextInput.text;
        BOOL        isPatient        = self.enrollmentIntroTableViewController.isPatientInput.on;
        
        //  Update `custom` SBBUserProfile properties in order to store app-specific user properties
        SBBUserProfile* profile = [[SBBUserProfile alloc] init];
        
        profile.can_be_recontacted = recontactAllowed ? @"YES" : @"NO";
        profile.recontact_number   = recontactNumber;
        profile.recontact_email    = recontactEmail;
        profile.mtsinai_patient    = isPatient ? @"YES" : @"NO";
        
        [theUser updateCustomProfile:profile onCompletion:nil];
        
        
        //  Update APCUser object
        theUser.allowContact = recontactAllowed;
        if (![recontactNumber isEqualToString:@""]) {
            theUser.phoneNumber = recontactNumber;
        }
    } else {
        //The user has selected no.
        theUser.allowContact = self.enrollmentIntroTableViewController.yesCellSelected;
    }

    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)]) {
            [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
        }
    }
}

@end
