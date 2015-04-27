//
//  MSSpectralSignatureSelectorTableVC.h
//  Spectral_Motion
//
//  Created by Kale Evans on 4/26/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SpectralSignaturesSelectionDelegate <NSObject>

-(void) didSelectSpectralSignaturesWithIndexPaths:(NSArray *) indexPaths;

@end

@interface MSSpectralSignatureSelectorTableVC : UITableViewController
@property(weak, nonatomic) id<SpectralSignaturesSelectionDelegate> delegate;

@end
