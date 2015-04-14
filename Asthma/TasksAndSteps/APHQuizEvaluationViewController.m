// 
//  APHQuizEvaluationViewController.m 
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
 
#import <APCAppCore/APCAppCore.h>
#import "APHQuizEvaluationViewController.h"
#import "QuizResultTableViewCell.h"
#import "APHQuizTextViewTableViewCell.h"
#import "APHConsentTask.h"
#import "APHConsentTaskViewController.h"

static NSString *incorrectIcon = @"consent_quiz_retry";
static NSString *correctIcon = @"valid_icon";

static NSString *quizAllCorrectText = @"You answered all of the questions correctly.\nTap Next to continue.";
static NSString *quizPassedText = @"You passed the quiz.\nTap Next to continue.";
static NSString *quizFailure1Text = @"Unfortunately, you answered one or more questions incorrectly on the quiz. We need you to repeat the quiz to make sure you understand what you need to know about the study.";
static NSString *quizFailure2Text = @"Unfortunately, you answered one or more questions incorrectly on the quiz. We need you to repeat the quiz to make sure you understand what you need to know about the study. Please read the consent information and take the quiz again.";

const float cellHeightPadding = 20;
static const float cellWidthPadding = 40;
const float defaultFontSize = 18.0;
const float nextButtonRowCellHeight = 54;


@interface APHQuizEvaluationTableView ()

@property (weak, nonatomic) ORKStepViewController *parentViewController;
@property (nonatomic, assign) BOOL          passedQuiz;
@property (nonatomic, assign) NSUInteger    failedAttempts;

@end


@implementation APHQuizEvaluationTableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        
    if (indexPath.section == 0) {
        QuizResultTableViewCell *resultCell = [tableView dequeueReusableCellWithIdentifier:@"QuizResultTableViewCell"];
        
        if (self.passedQuiz) {
            resultCell.resultIcon.image = [UIImage imageNamed:correctIcon];
            resultCell.resultTextLabel.text = NSLocalizedString(@"Great Job!", nil);
        }else{
            resultCell.resultIcon.image = [UIImage imageNamed:incorrectIcon];
            resultCell.resultTextLabel.text = NSLocalizedString(@"Try Again", nil);
        }
        
        [resultCell setAccessoryType:UITableViewCellAccessoryNone];
        return resultCell;
        
    }else if (indexPath.section == 1) {
        APHQuizTextViewTableViewCell *textViewCell =  [tableView dequeueReusableCellWithIdentifier:@"QuizTextViewTableViewCell"];
        [textViewCell setUserInteractionEnabled:NO];
        APHConsentTaskViewController *taskViewController = (APHConsentTaskViewController *)self.parentViewController.taskViewController;
        if (self.passedQuiz) {
            if (taskViewController.correctCount == 5) {
                textViewCell.textView.text = NSLocalizedString(quizAllCorrectText, nil);
            }else{
                textViewCell.textView.text = NSLocalizedString(quizPassedText, nil);
            }
            
        }else if (self.failedAttempts == 1){
            textViewCell.textView.text = NSLocalizedString(quizFailure1Text, nil);
        }else if (self.failedAttempts >1) {
            textViewCell.textView.text = NSLocalizedString(quizFailure2Text, nil);
        }

        textViewCell.textView.font = [UIFont appRegularFontWithSize:defaultFontSize];
        textViewCell.textView.textAlignment = NSTextAlignmentCenter;
        [textViewCell setAccessoryType:UITableViewCellAccessoryNone];
        return textViewCell;
        
    }else if (indexPath.section == 2) {
        APHQuizEvaluationNextButtonTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.controller = self;
        if (self.passedQuiz) {
            [cell.nextButton setTitle: NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
        }else if (self.failedAttempts == 1){
            [cell.nextButton setTitle:NSLocalizedString(@"Retake Quiz", nil) forState:UIControlStateNormal] ;
        }else{
            [cell.nextButton setTitle:NSLocalizedString(@"Review Consent", nil) forState:UIControlStateNormal];
        }
    
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell.nextButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.nextButton.titleLabel setTextColor:[UIColor appPrimaryColor]];
    
        return cell;
        
    }else{
        NSAssert(false, @"should not reach here");
        return nil;
    }
    
}

-(CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    APHConsentTask *consentTask = (APHConsentTask *)self.parentViewController.taskViewController.task;
    
    switch (indexPath.section) {
        case 0:
            return 150;
            break;
        case 1:
            if (self.passedQuiz) {
                return [self heightForText:quizPassedText fontSize:defaultFontSize];
            }else if (self.failedAttempts == 1){
                return [self heightForText:quizFailure1Text fontSize:defaultFontSize];
            }else if (self.failedAttempts >1) {
                return [self heightForText:quizFailure2Text fontSize:defaultFontSize];
            }

        case 2:
            return nextButtonRowCellHeight;
        default:
            return 44;
            break;
    }
    
}

-(CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 2) {
        return 44.0;
    }else{
        return 0.0;
    }
}

-(CGFloat)tableView:(UITableView *)__unused tableView heightForFooterInSection:(NSInteger)__unused section{
    return 0.0;
}

-(void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)__unused indexPath{
    
}

-(void) proceed{
    //go forward
    if ([self.parentViewController hasNextStep]) {
        [self.parentViewController goForward];
    }
    
}

-(CGFloat)heightForText:(NSString *)text fontSize: (double)fontSize{
    
    NSString *parseText = text;
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:@"\n" options:NSRegularExpressionIgnoreMetacharacters error:nil];
    int matches = (int)[regex numberOfMatchesInString:text options:0 range: NSMakeRange(0, text.length)];
    NSRange firstMatch = NSMakeRange(0, text.length);
    if (matches > 0) {
        CGFloat textHeight = 0;
        for (int i = 0; i < matches; i++) {
            //parse text and locate the range of first occurrence of \n
            firstMatch = [regex rangeOfFirstMatchInString:parseText options:0 range:firstMatch];
            
            //get the length of the text up to the \n
            parseText = [parseText substringToIndex:firstMatch.location];
            
            textHeight += ceil([parseText boundingRectWithSize:CGSizeMake(self.frame.size.width -cellWidthPadding, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont appRegularFontWithSize: fontSize]} context:nil].size.height + cellHeightPadding);
            
            parseText = [text substringFromIndex:firstMatch.location +1];//account for \n
            firstMatch = NSMakeRange(0, parseText.length);
        }
        
        textHeight += ceil([parseText boundingRectWithSize:CGSizeMake(self.frame.size.width -cellWidthPadding, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont appRegularFontWithSize: fontSize]} context:nil].size.height + cellHeightPadding);

        return textHeight;
    }else{
        return ceil([text boundingRectWithSize:CGSizeMake(self.frame.size.width -cellWidthPadding, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont appRegularFontWithSize: fontSize]} context:nil].size.height + cellHeightPadding);
    }
    
}

@end


@interface APHQuizEvaluationViewController ()

@property (weak, nonatomic) IBOutlet APHQuizEvaluationTableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@end

@implementation APHQuizEvaluationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self.tableView;
    self.tableView.dataSource = self.tableView;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.parentViewController = self;
    self.cancelButton = [[UIBarButtonItem alloc]init];
    
    self.tableView.passedQuiz = self.passedQuiz;
    self.tableView.failedAttempts = self.failedAttempts;
}

@end

@implementation APHQuizEvaluationNextButtonTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.nextButton.layer.cornerRadius = 5.0;
    self.nextButton.layer.borderColor = [[UIColor appPrimaryColor] CGColor];
    self.nextButton.layer.borderWidth = 1.0;
    self.nextButton.layer.masksToBounds = YES;
}

- (IBAction)nextButtonAction:(id)__unused sender {
    [self.controller performSelector:@selector(proceed) withObject:nil];
}   

@end
