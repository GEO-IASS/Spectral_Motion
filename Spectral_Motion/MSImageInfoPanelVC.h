//
//  MSImageInfoPanelVC.h
//  Spectral_Motion
//
//  Created by Kale Evans on 3/27/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSImageInfoPanelVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *imageTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@property (weak, nonatomic) IBOutlet UILabel *sampleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redPixelValueImageView;
@property (weak, nonatomic) IBOutlet UILabel *redPixelValLabel;
@property (weak, nonatomic) IBOutlet UIImageView *greenPixelValueImageView;
@property (weak, nonatomic) IBOutlet UILabel *greenPixelValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bluePixelValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bluePixelValueImageView;
@end
