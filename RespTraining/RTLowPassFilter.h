//
//  RTLowPassFilter.h
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/29/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//
//  Inspired by the Apple AccelerometerGraph example:
//  https://developer.apple.com/library/ios/samplecode/AccelerometerGraph/Listings/AccelerometerGraph_AccelerometerFilter_h.html#//apple_ref/doc/uid/DTS40007410-AccelerometerGraph_AccelerometerFilter_h-DontLinkElementID_3)
//
// For details on low-pass filtering see:
// https://en.wikipedia.org/wiki/Low-pass_filter
//

#import <Foundation/Foundation.h>

@interface RTLowPassFilter : NSObject
@property (nonatomic) BOOL adaptive; //triggers the filter to be adaptive vs regular
@property (nonatomic, readonly) double filterConstant;
@property (nonatomic, readonly) double  x;
@property (nonatomic, readonly) double lastX;

- (void)addValue:(double)x;
//designated initializer
- (instancetype)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;
@end