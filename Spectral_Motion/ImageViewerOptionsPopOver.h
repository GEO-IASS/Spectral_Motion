//
//  ImageViewerOptionsPopOver.h
//  Spectral_Motion
//
//  Created by Kale Evans on 3/27/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum SourceContext {
    
    ImageViewContext = 0,
    GraphViewContext
    
}SourceContext;

@protocol OptionSelectedDelegate <NSObject>

-(void)didSelectOption:(NSUInteger) optionSelected;

@end

@interface ImageViewerOptionsPopOver : UITableViewController
@property (nonatomic, weak) id <OptionSelectedDelegate> delegate;

-(id)initFromContext:(SourceContext) context;

@end
