//
//  RTMedianFilter.m
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/31/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import "RTMedianFilter.h"

static const size_t defaultOrder = 5;

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
    qsort(temp, self.order, sizeof(double), compare);
    self.x = temp[self.order / 2];
}

//designated initialiser
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

- (instancetype)init
{
    return [self initWithOrder:defaultOrder];
}

- (void)dealloc
{
    free(storage);
}

@end
