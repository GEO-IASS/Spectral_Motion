//
//  MSImageBlur.h
//  Spectral_Motion
//
//  Created by Kale Evans on 2/22/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MSImageBlur : NSObject

+ (UIImage *)takeSnapshotOfView:(UIView *)view;
+ (UIImage *)blurWithCoreImage:(UIImage *)sourceImage andView:(UIView*)view;


@end
