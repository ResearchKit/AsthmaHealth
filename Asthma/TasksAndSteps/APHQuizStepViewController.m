// 
//  APHQuizStepViewController.m 
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
 
#import "APHQuizStepViewController.h"
#import "APHBooleanQuestionStep.h"
#import "APHQuizQuestionTableViewCell.h"
#import "APHQuizTextViewTableViewCell.h"

@import APCAppCore;

static NSString *correctBadge = @"valid_icon";
static NSString *incorrectBadge = @"incorrect_icon";

static NSString *incorrectCliffhanger = @"The correct answer is ";
static NSString *correctCliffhanger = @"You are ";
static NSString *correct = @"correct. ";
static NSString *falseIsCorrect = @"false. ";
static NSString *trueIsCorrect = @"true. ";

static NSString *introText = @"Please answer a few review questions to ensure that you understand the consent form.";
static NSString *question1 = @"If my asthma gets worse during the study I should stop relying on the app and see my doctor.";
static NSString *question1TrueFeedback = @"The app does not replace your usual medical care. Continue asthma care with your usual doctor at all times and let him/her know you are in the study. If your asthma is getting worse at any time, including during the study, please contact your doctor.";
static NSString *question1FalseFeedback = @"The app does not replace your usual medical care. Continue asthma care with your usual doctor at all times and let him/her know you are in the study. If your asthma is getting worse at any time, including during the study, please contact your doctor.";

static NSString *question2 = @"Once I start participating in the study, I am free to withdraw at any time but the data I contributed will not be deleted.";
static NSString *question2TrueFeedback = @"You are free to withdraw at any time from the study. To withdraw, choose “Leave Study” on the app's “Profile” page, delete the app from your phone, or contact the researchers. Data you have contributed up until you withdraw will stay in the study but no further data will be gathered.";
static NSString *question2FalseFeedback = @"You are free to withdraw at any time from the study. To withdraw, choose “Leave Study” on the app's “Profile” page, delete the app from your phone, or contact the researchers. Data you have contributed up until you withdraw will stay in the study but no further data will be gathered.";

static NSString *question3 = @"This app is a research study and not a commercial application.";
static NSString *question3TrueFeedback = @"This is a research study and not a commercial application.";
static NSString *question3FalseFeedback = @"This is a research study and not a commercial application.";

@interface APHQuizStepTableView ()
@property (weak, nonatomic) APHQuizStepViewController *parentViewController;
@end

@implementation APHQuizStepTableView
static NSString * emphasizedAnswerFontName = @"Helvetica-BoldOblique";
static const float cellHeightPadding = 40;
static const float cellWidthPadding = 40;
static const float defaultFontSize = 18.0;
static const float kSmallFontSize = 14.0;
static const float quizInstructionFontSize = 16.0;

-(NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView{
    return 5;
}

-(NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    APHQuizStepNextButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.tableView = self;
    APHQuizQuestionTableViewCell *trueFalseCell = [tableView dequeueReusableCellWithIdentifier:@"APHQuizQuestionTableViewCell"];
    APHQuizTextViewTableViewCell *textViewCell = [tableView dequeueReusableCellWithIdentifier:@"QuizTextViewTableViewCell"];
    APHQuizTextViewTableViewCell *feedbackCell = [tableView dequeueReusableCellWithIdentifier:@"QuizFeedbackTableViewCell"];
    
    textViewCell.backgroundColor = [UIColor whiteColor];
    [textViewCell.textView setTextColor:[UIColor darkGrayColor]];
    
    switch (indexPath.section) {
        case 0:
            textViewCell.textView.text = introText;
            textViewCell.textView.font = [UIFont appRegularFontWithSize: quizInstructionFontSize];
            textViewCell.textView.textAlignment = NSTextAlignmentCenter;

            textViewCell.textView.backgroundColor = [UIColor whiteColor];
            [textViewCell.textView setTextColor:[UIColor appSecondaryColor1]];
            return textViewCell;
            
        case 1:
            textViewCell.backgroundColor = [UIColor whiteColor];
            textViewCell.textView.font = [UIFont appRegularFontWithSize: defaultFontSize];
            [textViewCell.textView setTextColor:[UIColor appSecondaryColor1]];
            textViewCell.textView.textAlignment = NSTextAlignmentCenter;
            if ([self.parentViewController.step.identifier isEqualToString:@"question1"]) {
                textViewCell.textView.text = NSLocalizedString(question1, nil);//critical question
            }
            if ([self.parentViewController.step.identifier isEqualToString:@"question2"]) {
                textViewCell.textView.text = NSLocalizedString(question2, nil);
            }
            if ([self.parentViewController.step.identifier isEqualToString:@"question3"]) {
                textViewCell.textView.text = NSLocalizedString(question3, nil);
            }
            return textViewCell;
            
        case 2:
            trueFalseCell.trueIcon.hidden = true;
            trueFalseCell.falseIcon.hidden = true;
            
            //did we submit?
            if (self.parentViewController.submitted == true) {
                [trueFalseCell setUserInteractionEnabled:NO];
                BOOL correct = [self.parentViewController evaluateResponse:self.selection];
                [self.parentViewController.delegate stepViewControllerResultDidChange:self.parentViewController];

                if (self.selection == true && correct == true) {
                    trueFalseCell.trueIcon.image = [UIImage imageNamed:correctBadge];
                    [trueFalseCell.trueIcon setHidden:NO];
                }
                if (self.selection == true && correct == false) {
                    trueFalseCell.trueIcon.image = [UIImage imageNamed:incorrectBadge];
                    [trueFalseCell.trueIcon setHidden:NO];
                }
                if (self.selection == false && correct == true) {
                    trueFalseCell.falseIcon.image = [UIImage imageNamed:correctBadge];
                    [trueFalseCell.falseIcon setHidden:NO];
                }
                if (self.selection == false && correct == false) {
                    trueFalseCell.falseIcon.image = [UIImage imageNamed:incorrectBadge];
                    [trueFalseCell.falseIcon setHidden:NO];
                }
                
                //redisplay the highlight on the selection
                [trueFalseCell didMakeSelection:self.selection];
            }else{
                [trueFalseCell setUserInteractionEnabled:YES];
            }
            
            return trueFalseCell;
        case 3:
            
            if (self.parentViewController.submitted == true) {
                //show the answer
                feedbackCell.textView.font = [UIFont appRegularFontWithSize: defaultFontSize];
                [feedbackCell.textView setTextColor:[UIColor appSecondaryColor1]];
                if ([self.parentViewController.step.identifier isEqualToString:@"question1"]) {
                    if (self.selection == false) {
                        feedbackCell.textView.attributedText = [self constructParagraphFromCliffhanger:incorrectCliffhanger answer:trueIsCorrect explanation:question1FalseFeedback];
                    }
                    if (self.selection == true) {
                        feedbackCell.textView.attributedText = [self constructParagraphFromCliffhanger:correctCliffhanger answer:correct explanation:question1TrueFeedback];
                    }
                }
                if ([self.parentViewController.step.identifier isEqualToString:@"question2"]) {
                    if (self.selection == false) {
                        feedbackCell.textView.attributedText = [self constructParagraphFromCliffhanger:incorrectCliffhanger answer:trueIsCorrect explanation:question2FalseFeedback];
                    }
                    if (self.selection == true) {
                        feedbackCell.textView.attributedText = [self constructParagraphFromCliffhanger:correctCliffhanger answer:correct explanation:question2TrueFeedback];
                    }
                }
                if ([self.parentViewController.step.identifier isEqualToString:@"question3"]) {
                    if (self.selection == false) {
                        feedbackCell.textView.attributedText = [self constructParagraphFromCliffhanger:incorrectCliffhanger answer:trueIsCorrect explanation:question3FalseFeedback];
                    }
                    if (self.selection == true) {
                        feedbackCell.textView.attributedText = [self constructParagraphFromCliffhanger:correctCliffhanger answer:correct explanation:question3TrueFeedback];
                    }
                }
            }
            return feedbackCell;
            
        case 4:
            //Next button
            trueFalseCell = (APHQuizQuestionTableViewCell*)[self cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
            if (self.parentViewController.submitted == true) {
                [cell.nextButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
            }else if ([trueFalseCell madeSelection]) {
                [cell.nextButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
                [cell.nextButton setEnabled:YES];
            }else{
                [cell.nextButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
                [cell.nextButton setEnabled:NO];
            }
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            return cell;
    }
    
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)__unused scrollView{
    
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)__unused scrollView{
    NSLog(@"scrollViewDidScrollToTop");
}



-(CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
            return [self heightForText:introText fontSize:kSmallFontSize];
        case 1:
            if ([self.parentViewController.step.identifier isEqualToString:@"question1"]) {
                return [self heightForText:question1 fontSize:defaultFontSize];
            }
            if ([self.parentViewController.step.identifier isEqualToString:@"question2"]) {
                return [self heightForText:question2 fontSize:defaultFontSize];
            }
            if ([self.parentViewController.step.identifier isEqualToString:@"question3"]) {
                return [self heightForText:question3 fontSize:defaultFontSize];
            }

        case 2:
            //True/False Buttons
            return 150.0;
            
        case 3:
            //Feedback
            if (self.parentViewController.submitted == false) {
                return 0.0;
            }else{
                //show the answer
                if ([self.parentViewController.step.identifier isEqualToString:@"question1"]) {
                    if (self.selection == false) {
                        return [self heightForText:question1FalseFeedback fontSize:defaultFontSize];
                    }
                    if (self.selection == true) {
                        return [self heightForText:question1TrueFeedback fontSize:defaultFontSize];
                    }
                }
                if ([self.parentViewController.step.identifier isEqualToString:@"question2"]) {
                    if (self.selection == false) {
                        return [self heightForText:question2FalseFeedback fontSize:defaultFontSize];
                    }
                    if (self.selection == true) {
                        return [self heightForText:question2TrueFeedback fontSize:defaultFontSize];
                    }
                }
                if ([self.parentViewController.step.identifier isEqualToString:@"question3"]) {
                    if (self.selection == false) {
                        return [self heightForText:question3FalseFeedback fontSize:defaultFontSize];
                    }
                    if (self.selection == true) {
                        return [self heightForText:question3TrueFeedback fontSize:defaultFontSize];
                    }
                }                
            }
            
        default:
            return 44;
    }
    
}

-(CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 4) {
        return 20;
    }else{
        return 0.0;
    }
    
}

-(UIView *)tableView:(UITableView *)__unused tableView viewForHeaderInSection:(NSInteger)__unused section{
    UIView *background = [[UIView alloc]init];
    background.backgroundColor = [UIColor whiteColor];
    return background;
}

-(CGFloat)tableView:(UITableView *)__unused tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == 4) {
        return 20;
    }else{
        return 0.0;
    }
    
}

-(UIView *)tableView:(UITableView *)__unused tableView viewForFooterInSection:(NSInteger)__unused section{
    UIView *background = [[UIView alloc]init];
    background.backgroundColor = [UIColor whiteColor];
    return background;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    APHQuizQuestionTableViewCell *questionCell = (APHQuizQuestionTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    
    //check if we're clicking to submit or clicking for next
    if (indexPath.section == 4) {
        if (self.parentViewController.submitted == true && [self.parentViewController hasNextStep]) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setUserInteractionEnabled:NO];
            [self.parentViewController goForward];
        }else if (questionCell.madeSelection == true){
            //Submit
            self.parentViewController.submitted = true;
            self.selection = questionCell.selection;
            [self reloadData];
        }else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}


-(CGFloat)heightForText:(NSString *)text fontSize: (double)fontSize{
    
    return ceil([text boundingRectWithSize:CGSizeMake(self.frame.size.width -cellWidthPadding, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont appRegularFontWithSize: fontSize]} context:nil].size.height + cellHeightPadding);
    
}

-(NSAttributedString *)constructParagraphFromCliffhanger: (NSString *)cliffhanger answer:(NSString *)italicAnswer explanation:(NSString*)explanation{
    UIFont *regularFont = [UIFont appRegularFontWithSize: defaultFontSize];
    UIFont *italicFont = [UIFont fontWithName:emphasizedAnswerFontName size:defaultFontSize];
    NSMutableAttributedString *quizFeedback = [[NSMutableAttributedString alloc]initWithString:cliffhanger];

    [quizFeedback addAttribute:NSFontAttributeName value:regularFont range:NSMakeRange(0, [cliffhanger length])];
    
    [quizFeedback appendAttributedString:[[NSMutableAttributedString alloc]initWithString:italicAnswer]];
    [quizFeedback addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange([cliffhanger length], [italicAnswer length])];

    [quizFeedback appendAttributedString:[[NSMutableAttributedString alloc]initWithString:explanation]];
    [quizFeedback addAttribute:NSFontAttributeName value:regularFont range:NSMakeRange([cliffhanger length] + [italicAnswer length], [explanation length])];
    
    return quizFeedback;
    
}

-(void) setNextCellSchemeColor: (id)__unused sender{
    APHQuizQuestionTableViewCell *questionCell = (APHQuizQuestionTableViewCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    questionCell.madeSelection = true;
    [self reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}

@end

@interface APHQuizStepViewController ()
@property (strong, nonatomic) IBOutlet APHQuizStepTableView *tableView;
@end

@implementation APHQuizStepViewController
#import "APHQuizQuestionTableViewCell.h"

static NSString *kUserMadeSelectionInQuizCellNotification = @"userMadeSelectionInQuizCellNotification";

-(void)viewDidLoad{
    [super viewDidLoad];
    self.questionResult = [[ORKBooleanQuestionResult alloc]initWithIdentifier:self.step.identifier];
    self.tableView.delegate = self.tableView;
    self.tableView.dataSource = self.tableView;
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(setNextCellSchemeColor:) name:kUserMadeSelectionInQuizCellNotification object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.parentViewController = self;
    self.submitted = false;
}

-(BOOL)evaluateResponse: (BOOL) response{
    
    APHBooleanQuestionStep *questionStep = (APHBooleanQuestionStep *)self.step;
    BOOL correct = questionStep.answer == response;
    self.questionResult.booleanAnswer = [NSNumber numberWithBool:correct];
    [self.delegate stepViewControllerResultDidChange:self];
    return correct;
}

@end

@implementation APHQuizStepNextButtonTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}
- (IBAction)nextButtonAction:(id)__unused sender {
    [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
    
}

@end
