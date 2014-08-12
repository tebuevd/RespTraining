//
//  RTSettingsViewController.h
//  RespTraining
//
//  Created by Dinislam Tebuev on 8/12/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTSettingsViewControllerDelegate <NSObject>

-(void)updateLowPass:(BOOL)lowPassOn medianPass:(BOOL)medianPassOn;

@end

@interface RTSettingsViewController : UITableViewController

@property (nonatomic, weak) id <RTSettingsViewControllerDelegate> delegate;
@property (nonatomic, getter=isLowPassOn) BOOL lowPassOn;
@property (nonatomic, getter=isMedianPassOn) BOOL medianPassOn;

@end
