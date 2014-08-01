//
//  RTViewController.h
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/21/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import <UIKit/UIKit.h>

//device frequency
static const double filterRate = 50;
static const double filterCutoffFrequency = 2;

@interface RTViewController : UIViewController <NSStreamDelegate>

@end
