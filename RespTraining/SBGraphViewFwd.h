//
//  SBGraphViewFwd.h
//  SimplyBreathe
//     (based on Apple's AccelerometerGraph Example: GraphView.h)
//  Created by Joseph Cheng on 1/15/14.
//  Copyright (c) 2014 Joseph Y Cheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    SBGraphViewState_Monitor = 1,
    SBGraphViewState_Caution = 2,
    SBGraphViewState_Warning = 4
} SBGraphViewState;

@interface SBGraphViewFwd : UIView

- (void)addX:(double)x;

- (void)resetGraph;
- (void)resetGraph:(bool)doAuto;
- (void)calcScaleCenterUserFromMax:(double)xmax min:(double)xmin;

@property (nonatomic) bool doAutoScale;

// Determine what to do when we are out of calibration bounds!
- (void)flagAboveMaxWith:(SBGraphViewState)state;
- (void)flagBelowMinWith:(SBGraphViewState)state;
@property (nonatomic, assign) CGFloat percentAccepted;

@end
