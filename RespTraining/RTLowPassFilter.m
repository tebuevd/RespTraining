//
//  RTLowPassFilter.m
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/29/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import "RTLowPassFilter.h"

@interface RTLowPassFilter()
//make writable
@property (nonatomic, readwrite) double filterConstant, x, lastX;

@end

@implementation RTLowPassFilter

//should not be used
- (instancetype)init
{
    return nil;
}

- (instancetype)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
    self = [super init];
    if (self) {
        double dt = 1.0 / rate;
        double RC = 1.0 / freq;
        self.filterConstant = dt / (dt + RC);
    }
    return self;
}

- (void)addValue:(double)x
{
    double alpha = self.filterConstant;
    self.x = x * alpha  + self.x * (1.0 - alpha);
}

@end
