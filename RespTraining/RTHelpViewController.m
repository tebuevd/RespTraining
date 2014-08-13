//
//  RTHelpViewController.m
//  RespTraining
//
//  Created by Dinislam Tebuev on 8/12/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import "RTHelpViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface RTHelpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *SSIDLabel;

@end

@implementation RTHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.SSIDLabel.text = [RTHelpViewController currentWifiSSID];
    if ([self.SSIDLabel.text isEqualToString:@"roving1"]) {
        self.SSIDLabel.textColor = [UIColor greenColor];
    } else {
        self.SSIDLabel.textColor = [UIColor redColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//back to previous view
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//See https://stackoverflow.com/questions/5198716/iphone-get-ssid-without-private-library
+ (NSString *)currentWifiSSID {
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}


@end
