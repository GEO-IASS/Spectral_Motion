//
//  MSColorMapPopOver.h
//  TableViewPopOverTest
//
//  Created by Kale Evans on 3/8/15.
//  Copyright (c) 2015 Star Micronics. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellSelected <NSObject>

-(void)colorCellSelectedWithIndex:(int)index;

@end

@interface MSColorMapPopOver : UITableViewController
@property (nonatomic, weak) id <CellSelected> delegate;


@end
