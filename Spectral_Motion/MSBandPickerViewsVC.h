//
//  MSBandPickerViewsVC.h
//  Spectral_Motion
//
//  Created by Kale Evans on 4/8/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "ViewController.h"
@protocol ImageGeneratedDelegate<NSObject>;

-(void)didFinishCreatingImage:(UIImage*) image;

@end

@interface MSBandPickerViewsVC : ViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property(weak, nonatomic) id<ImageGeneratedDelegate> delegate;

@property(strong,nonatomic) NSNumber *m_NumberOfBands;
@property(strong,nonatomic) NSNumber *m_ShouldShowColorOptions;
@property(strong,nonatomic) UINavigationController *m_ParentNavController;

@property (weak, nonatomic) IBOutlet UIPickerView *colorBandPickerView;
@property (weak, nonatomic) IBOutlet UIView *colorBandPickerViewBackground;

@property (weak, nonatomic) IBOutlet UIPickerView *greyscaleBandPickerView;
@property (weak, nonatomic) IBOutlet UIView *greyscalePickerViewBackground;

@end
