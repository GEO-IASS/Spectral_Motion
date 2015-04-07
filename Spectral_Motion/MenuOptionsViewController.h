//
//  MenuOptionsViewController.h
//  Spectral_Motion
//
//  Created by Kale Evans on 3/15/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionSelectedDelegate <NSObject>

-(void)didSelectOptionWithIndex:(NSUInteger) selectedOption;

@end

@interface MenuOptionsViewController : UITableViewController
@property(weak ,nonatomic) id<OptionSelected> delegate;

@end
