//
//  RTStatusMessages.h
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/21/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

typedef struct {
    BOOL lowPass;
    BOOL medianPass;
    NSInteger audioFile;
} Settings;

extern NSString * const kStatusConnect;
extern NSString * const kStatusConnecting;
extern NSString * const kStatusConnected;
extern NSString * const kStatusError;

extern NSString * const kAudioFiles[];
extern NSInteger const kNumAudioFiles;

extern Settings kDefaultSettings;