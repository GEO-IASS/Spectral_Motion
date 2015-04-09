//
//  MSBandPickerViewsVC.h
//  Spectral_Motion
//
//  Created by Kale Evans on 4/8/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "ViewController.h"

@interface MSBandPickerViewsVC : ViewController<UIPickerViewDataSource>
@property(strong,nonatomic) NSNumber *m_NumberOfBands;
@property(strong,nonatomic) NSNumber *m_ShouldShowColorOptions;

@property (weak, nonatomic) IBOutlet UIPickerView *redBandPickerView;
@property (weak, nonatomic) IBOutlet UIView *redBandPickerBackgroundView;
@property (weak, nonatomic) IBOutlet UIPickerView *greenBandPickerView;
@property (weak, nonatomic) IBOutlet UIView *greenBandPickerBackgroundView;
@property (weak, nonatomic) IBOutlet UIPickerView *blueBandPickerView;
@property (weak, nonatomic) IBOutlet UIView *blueBandPickerBackgroundView;

@end
