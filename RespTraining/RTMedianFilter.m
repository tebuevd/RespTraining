//
//  RTMedianFilter.m
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/31/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import "RTMedianFilter.h"

/*
 * Fastest way to find the median of an array of 7 numbers
 * http://ndevilla.free.fr/median/median/
 */
typedef double pixelvalue ;

#define PIX_SORT(a,b) { if ((a)>(b)) PIX_SWAP((a),(b)); }
#define PIX_SWAP(a,b) { pixelvalue temp=(a);(a)=(b);(b)=temp; }

pixelvalue opt_med7(pixelvalue * p)
{
    PIX_SORT(p[0], p[5]) ; PIX_SORT(p[0], p[3]) ; PIX_SORT(p[1], p[6]) ;
    PIX_SORT(p[2], p[4]) ; PIX_SORT(p[0], p[1]) ; PIX_SORT(p[3], p[5]) ;
    PIX_SORT(p[2], p[6]) ; PIX_SORT(p[2], p[3]) ; PIX_SORT(p[3], p[6]) ;
    PIX_SORT(p[4], p[5]) ; PIX_SORT(p[1], p[4]) ; PIX_SORT(p[1], p[3]) ;
    PIX_SORT(p[3], p[4]) ; return (p[3]) ;
}

static const size_t defaultOrder = 7;

@interface RTMedianFilter()
{
    double *storage; //pointer to an array of points
}
@property (nonatomic, readwrite) double x;
@property (nonatomic, readwrite) size_t order;
@end

@implementation RTMedianFilter

//compare function for the qsort
int compare(const void *first, const void *second)
{
    if (*(double *)first > *(double *)second) return 1;
    if (*(double *)second > *(double *)first) return -1;
    return 0;
}

//inputting a value to the filter
- (void)addValue:(double)value
{
    memmove((void *)storage, (const void *)(storage + 1),
            (self.order - 1) * sizeof(double));
    storage[self.order - 1] = value;
    
    //update the x
    double temp[self.order];
    memcpy(temp, storage, sizeof(temp));
    self.x = opt_med7(temp);
}


- (instancetype)initWithOrder:(size_t)order
{
    self = [super init];
    if (self) {
        assert(order > 1);
        if (order % 2 == 0) order++; //make sure order is odd
        storage = calloc(order, sizeof(double)); //allocate and init the memory
        if (!storage) return nil;
        self.order = order;
    }
    return self;
}

//designated initialiser
- (instancetype)init
{
    return [self initWithOrder:defaultOrder];
}

- (void)dealloc
{
    free(storage);
}

@end
