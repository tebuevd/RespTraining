//
//  RTViewController.h
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/21/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSettingsViewController.h"
#import "RTConstants.h"

//device frequency
static const double filterRate = 50;
static const double filterCutoffFrequency = 2;

@interface RTViewController : UIViewController <NSStreamDelegate, RTSettingsViewControllerDelegate>

//delegate methods - deprecated
-(void)updateLowPass:(BOOL)lowPassOn medianPass:(BOOL)medianPassOn;
-(void)updateSoundFileChoice:(NSInteger)choice;

//delegate methods - preferred
-(void)updateSettings:(Settings)settings;

@end
