//
//  RTViewController.m
//  RespTraining
//
//  Created by Dinislam Tebuev on 7/21/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import "RTViewController.h"
#import "RTStatusMessages.h"
#import "SBGraphViewFwd.h"
#import "SBData.h"

//device frequency
static const NSInteger deviceFrequency = 50;

@interface RTViewController ()
//this handles connecting to the device
@property (strong, nonatomic) NSInputStream *connection;

@property (strong, nonatomic) SBRespData *dataObject;

@property (strong, nonatomic) NSDate *today; //keep track of time
@property (strong, nonatomic) NSDateFormatter *formatter;

@property (atomic) NSInteger packetCount; //auto init to 0

//UI elements
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet SBGraphViewFwd *graphView;
//allows to control the sampling frequency
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//establish connection with server
- (void)initNetworkConnection
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

//lazy instantiations
- (SBRespData *)dataObject
{
    if (!_dataObject) _dataObject = [[SBRespData alloc] init];
    return _dataObject;
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
    if (self.packetCount++ % (int)self.rateSlider.value) return;
//    if (value > 462 || value < 440) return;
    //calculate the time interval since the start of the app
    NSDate *now = [NSDate date];
    double dt = [now timeIntervalSinceDate:self.today];
    NSLog(@"Value: %d Time: %f", value, dt);
    [self.graphView addX:value];
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
                        //ignore that first 0 then process the data
                        if (value) [self processData:value];
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
