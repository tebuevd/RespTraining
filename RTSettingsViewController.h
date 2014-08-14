//
//  RTSettingsViewController.h
//  RespTraining
//
//  Created by Dinislam Tebuev on 8/12/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTConstants.h"

@protocol RTSettingsViewControllerDelegate <NSObject>

-(void)updateLowPass:(BOOL)lowPassOn medianPass:(BOOL)medianPassOn; //deprecated
-(void)updateSoundFileChoice:(NSInteger)choice; //deprecated
-(void)updateSettings:(Settings)settings; //preferred

@end

@interface RTSettingsViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id <RTSettingsViewControllerDelegate> delegate;
@property (nonatomic) Settings settings;
@property (nonatomic, getter=isLowPassOn) BOOL lowPassOn;
@property (nonatomic, getter=isMedianPassOn) BOOL medianPassOn;
@property (nonatomic) NSInteger audioFileName;

@end