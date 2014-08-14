//
//  RTViewController.m
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/21/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "RTViewController.h"
#import "SBGraphViewFwd.h"
#import "RTLowPassFilter.h"
#import "RTMedianFilter.h"

@interface RTViewController ()
//this handles connecting to the device
@property (strong, nonatomic) NSInputStream *connection;

//sound to be played
@property (nonatomic, strong) AVAudioPlayer *sound;

//settings
@property (nonatomic) Settings settings;

@property (nonatomic, getter=isLowPassOn) BOOL lowPassOn;
@property (nonatomic, getter=isMedianPassOn) BOOL medianPassOn;
@property (nonatomic) NSInteger audioFileName;

@property (strong, nonatomic) RTMedianFilter *mFilter;
@property (strong, nonatomic) RTLowPassFilter *lFilter;
@property (atomic) BOOL filterFlag;

@property (strong, nonatomic) NSDate *today; //keep track of time
@property (strong, nonatomic) NSDateFormatter *formatter;

@property (atomic) NSInteger packetCount; //auto init to 0

//UI elements
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet SBGraphViewFwd *graphView;
@property (weak, nonatomic) IBOutlet UIButton *playSoundButton;
@end

@implementation RTViewController

//this method plays sound and turns the button into a stop button
- (IBAction)playSound:(id)sender {
    if ([self.playSoundButton.titleLabel.text isEqualToString:@"►"]) {
        NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BIDE" ofType:@"mp3"]];
        self.sound = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
        [self.sound setVolume:1.0];
        [self.sound play];
        [self.playSoundButton setTitle:@"◼︎" forState:UIControlStateNormal];
    } else {
        [self.sound stop];
        [self.playSoundButton setTitle:@"►" forState:UIControlStateNormal];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    //set up filters
    self.mFilter = [[RTMedianFilter alloc] init];
    self.lFilter = [[RTLowPassFilter alloc] initWithSampleRate:filterRate
                                               cutoffFrequency:filterCutoffFrequency];
    self.filterFlag = NO;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateLowPass:(BOOL)lowPassOn medianPass:(BOOL)medianPassOn
{
    self.lowPassOn = lowPassOn;
    self.medianPassOn = medianPassOn;
}

-(void)updateSoundFileChoice:(NSInteger)choice
{
    self.audioFileName = choice;
}

-(void)updateSettings:(Settings)settings
{
    self.settings = settings;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MainToSettings"]) {
        RTSettingsViewController *vc = (RTSettingsViewController *)[[segue destinationViewController] topViewController];
        vc.delegate = self;
        vc.lowPassOn = self.isLowPassOn;
        vc.medianPassOn = self.isMedianPassOn;
        vc.audioFileName = self.audioFileName;
    }
}

//establish connection with server
-(void)initNetworkConnection
{
    //TODO: add a timeout
    [self.connectButton setTitle:kStatusConnecting
                        forState:UIControlStateNormal];
    [self.connectButton setEnabled:NO];
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"1.2.3.4", 2000, &readStream, &writeStream);
    self.connection = (__bridge_transfer NSInputStream *)readStream;
    [self.connection setDelegate:self];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection open];
}

//called when button pressed
- (IBAction)connectToDevice {
    [self initNetworkConnection];
}

- (NSDateFormatter *)formatter
{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZ"];
    }
    return _formatter;
}

//method that takes care of processing the newly arrived value
- (void)processData:(int)value
{
    //sampling - disabled for now
    //if (self.packetCount++ % (int)self.rateSlider.value) return;
    //calculate the time interval since the start of the app
    NSDate *now = [NSDate date];
    double dt = [now timeIntervalSinceDate:self.today];
    
    [self.mFilter addValue:(double)value]; //median pass
    [self.lFilter addValue:self.mFilter.x];//low-pass
    
//    if (self.filterFlag) {
        [self.graphView addX:-self.lFilter.x];
        NSLog(@"Value: %f Time: %f", self.lFilter.x, dt);
//    } else {
//        [self.graphView addX:-value];
//        NSLog(@"Value: %d Time: %f", value, dt);
//    }
    
}

//wrapper method to update the state of the connect button
- (void)updateConnectButtonWithTitle:(NSString *)title Enabled:(BOOL)enabled
{
    [self.connectButton setTitle:title
                        forState:(UIControlStateNormal)];
    [self.connectButton setEnabled:enabled];
}

//this function is called everytime the stream experiences an event
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
        //connection successful
		case NSStreamEventOpenCompleted:
            self.today = [NSDate date]; //each time we connect, we reset the date
			NSLog(@"Connection established at %@", [self.formatter stringFromDate:self.today]);
            [self updateConnectButtonWithTitle:kStatusConnected Enabled:NO];
			break;
        
        //main case - stream received bytes
		case NSStreamEventHasBytesAvailable:
            if (theStream == self.connection) {
                uint8_t buffer[1024];
                NSInteger len;
                while ([self.connection hasBytesAvailable]) {
                    len = [self.connection read:buffer maxLength:sizeof(buffer)];
                    buffer[len] = '\0'; //put an end to the string
                    if (len > 0) {
                        int value = atoi((const char *)buffer);
                        [self processData:value];
                    }
                }
                
            }
			break;
        
        //error case
		case NSStreamEventErrorOccurred:
			NSLog(@"Cannot connect to the host!");
            [self updateConnectButtonWithTitle:kStatusError Enabled:YES];
			break;
        
        //end of connection
		case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [self updateConnectButtonWithTitle:kStatusConnect Enabled:YES];
			break;
            
		default:
			NSLog(@"Unknown event");
            [self updateConnectButtonWithTitle:kStatusConnect Enabled:YES];
	}
}

@end
