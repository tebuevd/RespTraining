//
//  SBData.m
//  SimplyBreathe
//
//  Created by Joseph Y Cheng on 12/6/13.
//  Copyright (c) 2013 Joseph Y Cheng. All rights reserved.
//

#import "SBData.h"
#import <Accelerate/Accelerate.h>

#define SBRESPDATA_DEFLEN 128
#define SBRESPDATA_OFF 10

@implementation SBRespData

- (id)init
{
    self = [self initWithCapacity:SBRESPDATA_DEFLEN];
    return self;
}

- (id)initWithCapacity:(float)newlen
{
    self = [super init];
    
    self->log2len = ceil(log2(newlen));
    self->len = 1 << self->log2len;
    
    self->index = 0;
    self->index_p = 0;
    self->_isReadyForRate = false;
    self->_isReadyForRateCur = false;
    
    self->x = (float*)malloc(self->len * sizeof(float));
    self->time = (float*)malloc(self->len * sizeof(float));
    self->dx = (float*)malloc(self->len * sizeof(float));
    
    // Setup period tracker
    self->t_max = 0; self->t_max_p = 0;
    self->dx_max = 0;
    self->isPeriodMeasured = false;
    
    self->iperiod = 0;
    self->nperiod = 10;
    self->period = (float*)malloc(self->nperiod * sizeof(float));
    self->iperiodcur = 0;
    self->nperiodcur = 2;
    self->periodcur = (float*)malloc(self->nperiodcur * sizeof(float));
    
    // Setup calibration
    self->stateCalib = SBRespDataInitial;
    
    // FFT Setup
    //self->fft_weights = vDSP_create_fftsetup(self->log2len, kFFTRadix2);
    //self->fft_scomplex.realp = (float*)malloc(self->len/2*sizeof(float));
    //self->fft_scomplex.imagp = (float*)malloc(self->len/2*sizeof(float));
    self->tmp = (float*)malloc(self->len*sizeof(float));
    
    return self;
}

- (void) dealloc
{
    free(x);
    free(time);
    free(dx);
    //free(fft_scomplex.realp);
    //free(fft_scomplex.imagp);
    free(tmp);
    
    free(period);
    free(periodcur);
    
    // Handled by compiler (for ARC)
    //[self dealloc];
}

#pragma mark - Calibration methods

- (void) startCalibForTime:(float)time1
{
    self->tcalib = time1;
    self->nperiodcal = 0;
    self->periodcal = 0;
    _xmax = -DBL_MAX;
    _xmin = DBL_MAX;
    self->stateCalib = SBRespDataCalibrating;
}

- (bool) reset
{
    self->index = 0;
    self->index_p = 0;
    self->_isReadyForRate = false;
    self->_isReadyForRateCur = false;
    
    // Setup period tracker
    self->t_max = 0; self->t_max_p = 0;
    self->dx_max = 0;
    
    self->iperiod = 0;
    self->iperiodcur = 0;
    
    return true;
}

- (void) addData:(float)value time:(float)t
{
    // Insert data
    x[index] = value;
    time[index] = t;
    if (index == index_p)
        dx[index] = 0;
    else
        dx[index] = ((float)x[index]-x[index_p])/(time[index]-time[index_p]);
    
    // Still something to calibrate
    if (self->stateCalib == SBRespDataCalibrating) {
        self->tcalib -= (time[index]-time[index_p]);
        if (value > _xmax) _xmax = value;
        if (value < _xmin) _xmin = value;
        if (self->tcalib <= 0) self->stateCalib = SBRespDataCalibrated;
    }
    
    // Only look at events when (slope > threshold)
    if (abs(dx[index]) > 0.1) {
        
        // Search through small time window for max
        if (dx[index] > 0.1)
        {
            if (dx_max < abs(dx[index]))
            {
                dx_max = abs(dx[index]);
                t_max = time[index];
            }
            
            isPeriodMeasured = true;
        }
        else
        {
            // Should have found the period by now, so let's update the period
            if (isPeriodMeasured)
            {
                double periodnow = t_max - t_max_p;
                //NSLog(@"Period: %g",periodnow);
                
                period[iperiod] = periodnow;
                periodcur[iperiodcur] = periodnow;
                
                // If calibrating, store info
                if (self->stateCalib == SBRespDataCalibrating)
                {
                    self->nperiodcal++;
                    self->periodcal += periodcur[iperiodcur];
                }
                
                // Increment counter
                iperiod++;
                if (iperiod >= nperiod)
                {
                    _isReadyForRate = true;
                    iperiod = 0;
                }
                
                iperiodcur++;
                if (iperiodcur >= nperiodcur) {
                    _isReadyForRateCur = true;
                    iperiodcur = 0;
                }

            }
            
            // Reset state to find next period
            t_max_p = t_max;
            dx_max = 0;
            isPeriodMeasured = false;
        }
        
    }
    
    // Store previous counter
    index_p = index;
    
    // Increment current counter
    index++;
    // Loop index counter to start
    if (index >= len)
        index = 0;
    
    
}

- (float) getRate
{
    float rate = 0;
    
    if (true || _isReadyForRate) {
        float mperiod;
        vDSP_meanv(period, 1, &mperiod, nperiod);
        rate = 60.0/mperiod;
    } else if (iperiod > 0) {
        float mperiod;
        vDSP_meanv(period, 1, &mperiod, iperiod);
        rate = 60.0/mperiod;
    }
    
    return rate;
}

- (float) getRateCur
{
    float rate = 0.0;
    
    if (true || _isReadyForRateCur) {
        float mperiod;
        vDSP_meanv(periodcur, 1, &mperiod, nperiodcur);
        rate = 60.0/mperiod;
    } else if (iperiodcur > 0) {
        float mperiod;
        vDSP_meanv(periodcur, 1, &mperiod, iperiodcur);
        rate = 60.0/mperiod;
    }
    
    return rate;
}

#pragma mark - Accesor Methods

- (float)getCurTimeInterval:(float)t
{
    return t - t_max_p;
}

- (NSUInteger)getSize
{
    return len;
}

- (bool)isReady
{
    return _isReadyForRate;
}

#pragma mark - Calibration Methods
- (bool)isCalibrated
{
    return self->stateCalib == SBRespDataCalibrated;
}
- (double)getRateCalib
{
    return 60.0/self->periodcal*self->nperiodcal;
}

@end
