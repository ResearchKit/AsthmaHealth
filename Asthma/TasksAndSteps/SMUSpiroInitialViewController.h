//
//  SMUSpiroInitialViewController.h
//  Asthma
//
//  Created by Eric Larson on 5/27/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <APCAppCore/APCAppCore.h>
#import "../../OpenSpirometry/OpenSpirometry/SpirometerEffortAnalyzer.h"


@interface SMUSpiroInitialViewController : APCStepViewController <SpirometerEffortDelegate>
@end
