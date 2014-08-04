//
//  RTMedianFilter.h
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/31/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTMedianFilter : NSObject

@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) size_t order; //order of the filter
- (void)addValue:(double)value;

//not used since filter is specifically implemented for arrays of size 7
// - (instancetype)initWithOrde:(size_t)order;

@end
