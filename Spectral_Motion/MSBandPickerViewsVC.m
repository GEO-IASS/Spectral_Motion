//
//  MSBandPickerViewsVC.m
//  Spectral_Motion
//
//  Created by Kale Evans on 4/8/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSBandPickerViewsVC.h"

@interface MSBandPickerViewsVC ()

-(void)setGreyscaleTitleForPickerLabel;

@end

@implementation MSBandPickerViewsVC
@synthesize m_NumberOfBands, m_ShouldShowColorOptions;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(m_ShouldShowColorOptions == 0)
    {
        self.greenBandPickerBackgroundView.hidden = YES;
        self.blueBandPickerBackgroundView.hidden = YES;
        [self setGreyscaleTitleForPickerLabel];
    }
}

-(void)setGreyscaleTitleForPickerLabel
{
    UILabel *greyscalePickerViewLabel = (UILabel*) [self.redBandPickerBackgroundView viewWithTag:10];
    
    greyscalePickerViewLabel.text = @"Select Greyscale Band";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIPickerView Datasource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return m_NumberOfBands.intValue;
}


#pragma mark - UIPickerView Delegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%li", (long)row];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
