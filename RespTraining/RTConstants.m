//
//  RTStatusMessages.m
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/21/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import "RTConstants.h"

//status messages for the connection button
NSString * const kStatusConnect = @"Connect";
NSString * const kStatusConnecting = @"Connecting...";
NSString * const kStatusConnected = @"Connected";
NSString * const kStatusError = @"Reconnect";

//array of filenames
NSString * const kAudioFiles[] =
{
    @"Obama",
    @"Bush",
    @"Clinton",
    @"Bush",
    @"Reagan",
    @"Carter"
};
NSInteger const kNumAudioFiles = 6;

//default settings
Settings kDefaultSettings = {YES, YES, 1};

