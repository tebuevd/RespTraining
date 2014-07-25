//
//  SBData.h
//  SimplyBreathe
//
//  Created by Joseph Y Cheng on 12/6/13.
//  Copyright (c) 2013 Joseph Y Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

typedef enum{
    SBRespDataInitial,
    SBRespDataCalibrating,
    SBRespDataCalibrated
} SBRespDataCalibState;

@interface SBRespData : NSObject
{
    // store data
    float* x;
    float* time;
    float* dx;
    
    // determine period
    float t_max, t_max_p;
    float dx_max;
    bool isPeriodMeasured;
    
    // for current period
    float* periodcur;
    NSUInteger iperiodcur;
    NSUInteger nperiodcur;
    
    // for running average of periods
    float* period;
    NSUInteger iperiod;
    NSUInteger nperiod;
    
    // data dimensions
    NSUInteger len;
    vDSP_Length log2len;
    NSUInteger index;
    NSUInteger index_p;
    
    // for calibration
    double periodcal;
    int nperiodcal;
    double tcalib;
    SBRespDataCalibState stateCalib;
    
    // tmp array for computation
    float* tmp;
}

/*!
    Creates a SBData object with a custom capacity.
    @param len
        Capacity of data object
    @return id
        Initialized SBData object
    @updated 2014-01-13
 */
- (id) initWithCapacity:(float)len;

/*!
    Adds data point.
    @param value
        Data point value
    @param t
        Time associated with the data point
 */
- (void)addData:(float)value time:(float)t;

/*!
    Starts calibration with a given time duration.
    @param time
        Duration for calibration
    @updated 2014-01-16
 */
- (void)startCalibForTime:(float)time;

- (bool)reset;
- (float)getRateCur;
- (float)getRate;
- (bool)isReady;
- (NSUInteger)getSize;

// determine if ready to compute rate
@property(readonly,nonatomic) bool isReadyForRate;
@property(readonly,nonatomic) bool isReadyForRateCur;

// for calibration
@property(readonly,nonatomic) double xmin;
@property(readonly,nonatomic) double xmax;
- (bool)isCalibrated;
- (double)getRateCalib;

@end