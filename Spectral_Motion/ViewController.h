//
//  ViewController.h
//  Spectral Motion
//
//  Created by Kale Evans on 12/23/14.
//  Copyright (c) 2014 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSHyperspectralData.h"


@interface ViewController : UIViewController<UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UISlider *bandSlider;

- (IBAction)sliderValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *sliderValueLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewForImage;

-(void)setImageViewWithImage:(UIImage*)image;
-(void)setHyperspectralDataPointer:(MSHyperspectralData*)hyperspectralData;
-(void)setGreyScaleBand:(int)greyscaleBand;



@end

