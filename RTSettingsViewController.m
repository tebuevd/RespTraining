//
//  RTSettingsViewController.m
//  RespTraining
//
//  Created by Dinislam Tebuev on 8/12/14.
//  Copyright (c) 2014 Dinislam Tebuev. All rights reserved.
//

#import "RTSettingsViewController.h"

@interface RTSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *lowPassSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *medianPassSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *audioFilePicker;
@end

@implementation RTSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lowPassSwitch.on = self.isLowPassOn;
    self.medianPassSwitch.on = self.isMedianPassOn;
    
    self.audioFilePicker.dataSource = self;
    self.audioFilePicker.delegate = self;
    [self.audioFilePicker selectRow:self.audioFileName inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//dismisses the view controller
- (IBAction)done:(id)sender {
    [self.delegate updateLowPass:self.lowPassSwitch.isOn medianPass:self.medianPassSwitch.isOn];
    [self.delegate updateSoundFileChoice:self.audioFileName];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* UIPickerViewDataSource required methods */

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return kNumAudioFiles;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return kAudioFiles[row];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.audioFileName = row;
}

/* ------------ END ------------ */

@end
